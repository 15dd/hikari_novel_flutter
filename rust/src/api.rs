use anyhow::Result;

use crate::client;

#[derive(Clone)]
pub struct HttpHeader {
    pub name: String,
    pub value: String,
}

pub struct HttpResponse {
    pub status: u16,
    pub headers: Vec<HttpHeader>,
    pub body: Vec<u8>,
}

#[derive(Clone)]
pub struct StoredCookie {
    pub domain: String,
    pub name: String,
    pub value: String,
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn http_get(url: String, headers: Vec<HttpHeader>, follow_redirects: bool) -> Result<HttpResponse> {
    client::request(wreq::Method::GET, &url, headers, Vec::new(), follow_redirects).await
}

pub async fn http_post(url: String, headers: Vec<HttpHeader>, body: Vec<u8>, follow_redirects: bool) -> Result<HttpResponse> {
    client::request(wreq::Method::POST, &url, headers, body, follow_redirects).await
}

pub fn import_cookies(domain: String, cookies: Vec<HttpHeader>) -> Result<()> {
    client::import_cookies(&domain, &cookies);
    Ok(())
}

pub fn export_cookies() -> Vec<StoredCookie> {
    client::export_cookies()
}

pub fn clear_cookies() {
    client::clear_cookies();
}
