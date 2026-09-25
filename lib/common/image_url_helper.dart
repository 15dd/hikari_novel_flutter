/// 图片链接兼容处理
///
/// 数据源里有些图片会使用 `pic.777743.xyz` 这种镜像域名。
/// 在不同网络环境下，某些域名可能会出现 DNS 解析失败或被拦截，从而导致图片加载/缓存失败。
///
/// 这里采用“优先原链接、失败再兜底”的策略：
/// - `normalize()` 只做链接补全与协议修正，不强制替换域名避免把可用的域名换成不可用的）
/// - `fallback()` 返回一个可能可用的备用链接（例如替换为wenku8官方图片域名）
class ImageUrlHelper {
  /// 将解析出来的 img src 规范化为可请求的绝对 URL（不强制换域名）
  static String normalize(String src) {
    var s = src.trim();
    if (s.isEmpty) return s;

    // //xxx 这种协议相对链接
    if (s.startsWith('//')) {
      s = 'https:$s';
    }

    // /xxx 这种路径相对链接（通常挂在站点根目录）
    if (s.startsWith('/')) {
      // 图片通常在 pic 域名下，这里用官方域名兜底
      s = 'https://pic.wenku8.com$s';
    }

    // 尝试解析
    Uri uri;
    try {
      uri = Uri.parse(s);
    } catch (_) {
      return s;
    }

    // 有些页面可能会给出 http，这里尽量升级到 https（更少被拦截）
    if (uri.scheme == 'http') {
      uri = uri.replace(scheme: 'https');
      return uri.toString();
    }

    return s;
  }

  /// 根据已知不稳定域名，返回一个备用链接（可能为空或与原链接相同）
  static String fallback(String url) {
    final normalized = normalize(url);

    Uri uri;
    try {
      uri = Uri.parse(normalized);
    } catch (_) {
      return normalized;
    }

    final host = uri.host.toLowerCase();

    if (host == 'pic.777743.xyz') {
      // 备用：替换为wenku8官方图片域名（同路径）
      return uri.replace(host: 'pic.wenku8.com').toString();
    }

    return normalized;
  }
}
