use anyhow::{Context, Result};
use cookie::Cookie;
use once_cell::sync::Lazy;
use wreq::cookie::{CookieStore, Cookies};
use wreq::header::{HeaderMap, HeaderName, HeaderValue, ACCEPT_LANGUAGE};
use wreq::{Client, Method, Uri, Version};
use wreq_util::{Emulation, Platform, Profile};
use std::sync::{Arc, Mutex};

use crate::api::{HttpHeader, HttpResponse, StoredCookie};

struct MemoryCookieStore {
    cookies: Mutex<Vec<StoredCookie>>,
}

impl MemoryCookieStore {
    fn upsert(&self, domain: String, name: String, value: String) {
        let mut jar = self.cookies.lock().expect("cookie jar");
        if let Some(existing) = jar.iter_mut().find(|cookie| cookie.domain == domain && cookie.name == name) {
            existing.value = value;
        } else {
            jar.push(StoredCookie { domain, name, value });
        }
    }
}

impl CookieStore for MemoryCookieStore {
    fn set_cookies(&self, cookie_headers: &mut dyn Iterator<Item = &HeaderValue>, uri: &Uri) {
        let host = uri.host().unwrap_or("").to_string();
        for header in cookie_headers {
            let Ok(text) = header.to_str() else { continue };
            let Ok(cookie) = Cookie::parse(text) else { continue };
            let domain = cookie
                .domain()
                .map(|domain| domain.trim_start_matches('.').to_string())
                .filter(|domain| !domain.is_empty())
                .unwrap_or(host.clone());
            self.upsert(domain, cookie.name().to_string(), cookie.value().to_string());
        }
    }

    fn cookies(&self, uri: &Uri, _version: Version) -> Cookies {
        let host = uri.host().unwrap_or("");
        let jar = self.cookies.lock().expect("cookie jar");
        let pairs: Vec<String> = jar
            .iter()
            .filter(|cookie| host == cookie.domain || host.ends_with(&format!(".{}", cookie.domain)))
            .map(|cookie| format!("{}={}", cookie.name, cookie.value))
            .collect();
        if pairs.is_empty() {
            return Cookies::Empty;
        }
        HeaderValue::from_str(&pairs.join("; "))
            .map(Cookies::Compressed)
            .unwrap_or(Cookies::Empty)
    }
}

struct Clients {
    follow: Client,
    no_follow: Client,
    store: Arc<MemoryCookieStore>,
}

fn default_headers() -> HeaderMap {
    // UA、Accept、sec-ch-ua 由 Chrome136 指纹自带。这里只覆盖语言，方便以后在 zh-CN / zh-TW 之间切换。
    let mut headers = HeaderMap::new();
    headers.insert(ACCEPT_LANGUAGE, HeaderValue::from_static("zh-CN,zh;q=0.9,en;q=0.8"));
    headers
}

fn build_client(store: Arc<MemoryCookieStore>, follow_redirects: bool) -> Client {
    // emulation 会覆盖已有的 TLS/HTTP2/默认头，必须放在其它配置之前。
    // wreq 默认会跟随重定向；不跟随的客户端要显式关掉。
    let mut builder = Client::builder()
        .emulation(
            Emulation::builder()
                .profile(Profile::Chrome136)
                .platform(Platform::MacOS)
                .build(),
        )
        .cookie_provider(store)
        .default_headers(default_headers())
        .gzip(true);
    builder = builder.redirect(if follow_redirects {
        wreq::redirect::Policy::limited(10)
    } else {
        wreq::redirect::Policy::none()
    });
    builder.build().expect("wreq client")
}

static CLIENTS: Lazy<Clients> = Lazy::new(|| {
    let store = Arc::new(MemoryCookieStore { cookies: Mutex::new(Vec::new()) });
    Clients {
        follow: build_client(Arc::clone(&store), true),
        no_follow: build_client(Arc::clone(&store), false),
        store,
    }
});

pub async fn request(method: Method, url: &str, headers: Vec<HttpHeader>, body: Vec<u8>, follow_redirects: bool) -> Result<HttpResponse> {
    let client = if follow_redirects { &CLIENTS.follow } else { &CLIENTS.no_follow };
    let mut builder = client.request(method, url);
    for header in headers {
        let name = HeaderName::from_bytes(header.name.as_bytes()).with_context(|| format!("invalid header {}", header.name))?;
        let value = HeaderValue::from_str(&header.value).with_context(|| format!("invalid header {}", header.name))?;
        builder = builder.header(name, value);
    }
    if !body.is_empty() {
        builder = builder.body(body);
    }
    let response = builder.send().await?;
    let status = response.status();
    let headers = response
        .headers()
        .iter()
        .filter_map(|(name, value)| value.to_str().ok().map(|value| HttpHeader { name: name.to_string(), value: value.to_string() }))
        .collect();
    let body = response.bytes().await?.to_vec();
    Ok(HttpResponse { status: status.as_u16(), headers, body })
}

pub fn import_cookies(domain: &str, cookies: &[HttpHeader]) {
    let domain = domain.trim_start_matches('.').to_string();
    for cookie in cookies {
        CLIENTS.store.upsert(domain.clone(), cookie.name.clone(), cookie.value.clone());
    }
}

pub fn export_cookies() -> Vec<StoredCookie> {
    CLIENTS.store.cookies.lock().expect("cookie jar").clone()
}

pub fn clear_cookies() {
    CLIENTS.store.cookies.lock().expect("cookie jar").clear();
}
