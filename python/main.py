"""模拟登录流程（curl_cffi 模仿 Chrome 握手版本）。

通过 curl_cffi 的 impersonate="chrome150" 模仿 Chrome 的 TLS/JA3 指纹与请求头，
以通过 Cloudflare 的 Bot 检测。按应用的请求顺序串行访问首页、登录页、验证码、
登录和用户信息，再用同一会话请求排行榜「最近更新」「最新入库」、分类「欢乐向」按更新，随后拉取默认书架、目录和第一章正文，并随机抽一个书架分类试一次。打印每一步的状态和登录后的 Cookie。
"""

import os
import random
import re
import sys
import time
from pathlib import Path

from curl_cffi import requests

sys.path.insert(0, str(Path(__file__).resolve().parent))
from account import PASSWORD, USERNAME

HERE = Path(__file__).resolve().parent
HOST = "https://www.wenku8.net"

CF_MARKERS = ("__cf_chl_", "Just a moment", "Attention Required", "Enable JavaScript")


def text_of(response):
    return response.content.decode("gbk", errors="replace")


def snippet(html, limit=300):
    compact = " ".join(html.split())
    return compact[:limit]


def hint(html):
    marks = []
    if 'id="content"' in html or "id='content'" in html:
        marks.append('含 id="content"')
    for phrase in ("出现错误", "出現錯誤", "校验码错误", "校驗碼錯誤", "验证码过期", "驗證碼過期", "用户不存在", "用戶不存在", "密码错误", "密碼錯誤"):
        if phrase in html:
            marks.append(phrase)
    return ", ".join(marks) if marks else snippet(html)


def looks_like_cloudflare(html):
    return any(marker in html for marker in CF_MARKERS)


def show(name, response):
    method = getattr(response.request, "method", "GET") if response.request else "GET"
    print(f"[{name}] {method} {response.url} -> {response.status_code}")


def prepare(session):
    response = session.get(f"{HOST}/", timeout=30)
    show("首页", response)


def fetch_checkcode(session):
    """检测登录是否需要验证码。

    返回验证码字符串；若无需验证码则返回 None 并打印跳过日志。
    """
    # 先看登录页是否要求验证码
    login_page = session.get(f"{HOST}/login.php", timeout=30)
    show("登录页", login_page)
    login_html = text_of(login_page)
    if looks_like_cloudflare(login_html):
        print("  Cloudflare 检查页：指纹仍未通过，建议更换网络或 VPN 后重试")
        return None

    if "checkcode" not in login_html:
        print("[验证码] 登录页未要求验证码，跳过")
        return None

    url = f"{HOST}/checkcode.php?random={int(time.time() * 1000)}"
    response = session.get(url, headers={"Referer": f"{HOST}/login.php"}, timeout=30)
    show("验证码", response)
    content_type = response.headers.get("content-type", "")
    if response.status_code == 200 and content_type.startswith("image/"):
        path = HERE / "checkcode.png"
        path.write_bytes(response.content)
        if os.name == "nt":
            os.startfile(path)
        else:
            print(f"验证码已保存: {path}")
        return input("验证码: ").strip()
    print(snippet(text_of(response)))
    return None


def login(session, checkcode):
    data = {
        "username": USERNAME,
        "password": PASSWORD,
        "usecookie": "315360000",
        "action": "login",
    }
    if checkcode:
        data["checkcode"] = checkcode
    response = session.post(
        f"{HOST}/login.php",
        data=data,
        headers={"Referer": f"{HOST}/login.php"},
        allow_redirects=False,
        timeout=30,
    )
    show("登录", response)
    html = text_of(response)
    if "登录成功" in html or "登錄成功" in html:
        print("登录成功")
        print("Cookie:")
        for cookie in session.cookies.jar:
            print(f"  {cookie.name}={cookie.value}")
        return True
    print(hint(html))
    return False


def load_ranking(session, sort, page=1):
    url = f"{HOST}/modules/article/toplist.php?sort={sort}&page={page}"
    response = session.get(url, timeout=30)
    show(f"排行榜 {sort}", response)
    mitigated = response.headers.get("cf-mitigated", "")
    if mitigated:
        print(f"  cf-mitigated: {mitigated}")
    html = text_of(response)
    if "challenge" in mitigated.lower():
        print("  人机验证：响应头 cf-mitigated 含 challenge")
        return
    if looks_like_cloudflare(html):
        print("  Cloudflare 检查页：榜单请求被拦截")
        return
    if 'id="content"' not in html and "id='content'" not in html:
        print(f"  {hint(html)}")
        return
    style = "width:373px;height:136px;float:left;margin:5px 0px 5px 5px;"
    count = html.count(style)
    print(f"  书目数量: {count}")


def load_category(session, name, sort, page=1):
    # 标签名按 GBK 百分号编码放进 t=，不附加 charset。
    # sort 0 是按更新，与应用「按更新查看」的 v=0 相同。
    tag = "".join(f"%{byte:02X}" for byte in name.encode("gbk"))
    url = f"{HOST}/modules/article/tags.php?t={tag}&v={sort}&page={page}"
    response = session.get(url, timeout=30)
    show(f"分类 {name}", response)
    mitigated = response.headers.get("cf-mitigated", "")
    if mitigated:
        print(f"  cf-mitigated: {mitigated}")
    html = text_of(response)
    if "challenge" in mitigated.lower():
        print("  人机验证：响应头 cf-mitigated 含 challenge")
        return
    if looks_like_cloudflare(html):
        print("  Cloudflare 检查页：分类请求被拦截")
        return
    if 'id="content"' not in html and "id='content'" not in html:
        print(f"  {hint(html)}")
        return
    style = "width:373px;height:136px;float:left;margin:5px 0px 5px 5px;"
    print(f"  书目数量: {html.count(style)}")


def load_bookshelves(session, class_id):
    # 注意：bookcase.php 带 charset=gbk 参数会触发 Cloudflare WAF 403，
    # 因此这里不带 charset (页面本身仍是 GBK 编码)
    url = f"{HOST}/modules/article/bookcase.php?classid={class_id}"
    retries = 3
    for attempt in range(retries):
        response = session.get(url, timeout=30)
        if response.status_code != 429:
            break
        wait = 5 * (attempt + 1)
        print(f"  Cloudflare 限流（429），{wait}s 后重试（{attempt + 1}/{retries}）")
        time.sleep(wait)
    show(f"书架 {class_id}", response)
    html = text_of(response)
    if response.status_code == 429:
        print("  Cloudflare 限流（429），已达到最大重试次数")
        return
    if looks_like_cloudflare(html):
        print("  Cloudflare 检查页：书架请求被拦截")
        print("  可尝试更新 curl_cffi 或改用其他 impersonate 版本")
        return
    if 'name="classlist"' not in html:
        print(f"  {hint(html)}")
        return

    # 每个书条目：<td class="odd" ...><input type="checkbox" ...>（表头的 checkall 在 th 内，不计入）
    count = len(re.findall(r'<td class="?odd"?[^>]*>\s*<input[^>]*type="?checkbox', html))
    print(f"  书名数量: {count}")


def _blocked(response, html, label):
    mitigated = response.headers.get("cf-mitigated", "")
    if mitigated:
        print(f"  cf-mitigated: {mitigated}")
    if "challenge" in mitigated.lower():
        print(f"  人机验证：{label}")
        return True
    if looks_like_cloudflare(html):
        print(f"  Cloudflare 检查页：{label}")
        return True
    return False


def load_reader(session, aid):
    # articleinfo.php (详情), reader.php (目录) 带上书籍页 Referer, 接近从 /book/{aid}.htm 点进来
    detail_url = f"{HOST}/modules/article/articleinfo.php?id={aid}"
    response = session.get(detail_url, timeout=30)
    show(f"详情 {aid}", response)
    html = text_of(response)
    if _blocked(response, html, "详情被拦截"):
        return
    if 'id="content"' in html or "id='content'" in html:
        print('  含 id="content"')
    else:
        print(f"  {hint(html)}")

    time.sleep(1.0)
    book_url = f"{HOST}/book/{aid}.htm"
    catalogue_url = f"{HOST}/modules/article/reader.php?aid={aid}"
    response = session.get(catalogue_url, headers={"Referer": book_url}, timeout=30)
    show(f"目录 {aid}", response)
    html = text_of(response)
    if _blocked(response, html, "目录被拦截"):
        return
    cids = re.findall(r"&cid=(\d+)", html)
    if not cids:
        print(f"  {hint(html)}")
        return
    print(f"  章节数量: {len(cids)}")

    time.sleep(1.0)
    cid = cids[0]
    content_url = f"{HOST}/modules/article/reader.php?aid={aid}&cid={cid}"
    response = session.get(content_url, headers={"Referer": catalogue_url}, timeout=30)
    show(f"正文 {aid}/{cid}", response)
    html = text_of(response)
    if _blocked(response, html, "正文被拦截"):
        return
    if 'id="content"' not in html and "id='content'" not in html:
        print(f"  {hint(html)}")
        return
    print('  含 id="content"')


def main():
    if not USERNAME.strip() or not PASSWORD.strip():
        print("请先在 account.py 里填写 USERNAME 和 PASSWORD")
        return

    session = requests.Session(impersonate="chrome136")
    session.headers.update({ "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8" })

    prepare(session)
    checkcode = fetch_checkcode(session)
    if not login(session, checkcode):
        return

    response = session.get(f"{HOST}/userdetail.php?charset=gbk", timeout=30)
    show("用户信息", response)
    print(f"  {hint(text_of(response))}")

    load_ranking(session, "lastupdate")
    time.sleep(1.0)
    load_ranking(session, "postdate")
    time.sleep(1.0)
    load_category(session, "欢乐向", "0")

    load_bookshelves(session, 0)
    time.sleep(1.0)
    load_reader(session, 3354)
    time.sleep(1.0)
    load_bookshelves(session, random.choice(range(1, 6)))


if __name__ == "__main__":
    main()
