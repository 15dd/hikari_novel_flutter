import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/models/novel_detail.dart';
import 'package:hikari_novel_flutter/models/recommend_block.dart';
import 'package:hikari_novel_flutter/models/reply_item.dart';
import 'package:hikari_novel_flutter/network/api.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'image_url_helper.dart';

import '../common/log.dart';
import '../common/util.dart';
import '../models/bookshelf.dart';
import '../models/cat_chapter.dart';
import '../models/cat_volume.dart';
import '../models/comment_item.dart';
import '../models/content.dart';
import '../models/novel_cover.dart';
import '../models/user_info.dart';

///此部分的代码基本都是沿用之前的逻辑，然后用AI转化了下
class Parser {
  static List<NovelCover> parseToList(String htmlContent) {
    final node = Api.wenku8Node.node.replaceAll("https://", "");
    final List<NovelCover> result = [];
    final Document document = parse(htmlContent);

    final Element? contentElement = document.getElementById("content");
    if (contentElement == null) {
      return result;
    }
    const String targetStyle = "width:373px;height:136px;float:left;margin:5px 0px 5px 5px;";
    final List<Element> bookItems = contentElement.querySelectorAll('[style="$targetStyle"]');

    for (final Element novelItem in bookItems) {
      try {
        final Element? imgElement = novelItem.querySelector("img");
        String img = imgElement?.attributes['src'] ?? '';
        img = ImageUrlHelper.normalize(img);

        final Element? titleLinkElement = novelItem.querySelector("a");
        final String title = titleLinkElement?.attributes['title'] ?? "";

        final Element? divElement = novelItem.querySelector("div");
        final Element? detailLinkElement = divElement?.querySelector("a");
        final String href = detailLinkElement?.attributes['href'] ?? '';
        final String detailUrl = (href.isNotEmpty) ? "https://$node$href" : '';

        if (detailUrl.isEmpty) {
          continue;
        }

        if (img == "/images/noimg.jpg") {
          img = "https://$node/modules/article/images/nocover.jpg";
        } else if (img.isEmpty) {
          img = "https://$node/modules/article/images/nocover.jpg";
        }

        String aid = "";

        final bookIndex = detailUrl.indexOf("book/");
        final htmIndex = detailUrl.indexOf(".htm");
        if (bookIndex != -1 && htmIndex != -1 && htmIndex > bookIndex + 5) {
          aid = detailUrl.substring(bookIndex + 5, htmIndex);
        } else {
          final aidIndex = detailUrl.indexOf("aid=");
          final bidIndex = detailUrl.indexOf("&bid=");
          if (aidIndex != -1 && bidIndex != -1 && bidIndex > aidIndex + 4) {
            aid = detailUrl.substring(aidIndex + 4, bidIndex);
          }
        }

        if (title != "" && detailUrl.isNotEmpty) {
          result.add(NovelCover(title, img, aid));
        } else {}
      } catch (e, stackTrace) {
        Log.e(stackTrace);
      }
    }

    return result;
  }

  static List<NovelCover> parseOtherBookshelfToList(String html) {
    final List<NovelCover> list = [];
    final Document document = parse(html);
    final Element? content = document.getElementById('centerm');
    if (content != null) {
      final List<Element> trElements = content.getElementsByTagName('tr');
      for (int index = 1; index < trElements.length; index++) {
        final Element element = trElements[index];
        final List<Element> anchorElements = element.getElementsByTagName('a');
        if (anchorElements.length >= 2) {
          final String title = anchorElements[0].text.trim();
          final String href = anchorElements[1].attributes['href'] ?? '';
          final String aid = Uri.parse(href).queryParameters['bid'] ?? '';
          list.add(NovelCover(title, null, aid));
        }
      }
    }
    return list;
  }

  static NovelDetail getNovelDetail(String html) {
    bool isOffShelves = false;
    final Document document = parse(html);
    final Element? t1 = document.getElementById('content');
    final Element t2 = t1!.getElementsByTagName('table')[0];
    final String title = t2.querySelector('span > b')?.text.trim() ?? '';
    final trs = t2.getElementsByTagName('tr');
    final tds = trs[2].getElementsByTagName('td');
    final String author = tds[1].text.trim().substring(5);
    final String status = tds[2].text.trim().substring(5);
    String finUpdate;
    try {
      finUpdate = tds[3].text.trim().substring(5) + "update".tr;
    } catch (_) {
      isOffShelves = true;
      finUpdate = "delisted".tr;
    }
    String imgUrl = t1.getElementsByTagName('img')[0].attributes['src'] ?? '';
    imgUrl = ImageUrlHelper.normalize(imgUrl);
    final table2 = t1.getElementsByTagName('table')[2];
    final td2 = table2.getElementsByTagName('td')[1];
    final spans = td2.getElementsByTagName('span');
    String introduce = spans[5].innerHtml.replaceAll("<br>", "\n");
    final String tag = spans[0].text;
    String tempHeat = spans[1].text;
    bool isAnimated = false;
    try {
      table2.getElementsByTagName('td')[0].getElementsByTagName('span')[0].text;
      isAnimated = true;
    } catch (_) {
      isAnimated = false;
    }
    if (isOffShelves) {
      introduce = tempHeat;
      tempHeat = "not_trending".tr;
    } else {
      final rawDate = finUpdate.split("update".tr)[0];
      finUpdate = Util.getDateTime(rawDate) + "update".tr;
      finUpdate = finUpdate.trim();
    }
    String trending;
    try {
      trending = "increase_rate".tr + tempHeat.substring(18, 20);
    } catch (_) {
      trending = "increase_rate".tr + tempHeat.substring(18, 19);
    }
    final tags = tag.replaceRange(0, 7, "").split(" ");
    final heat = "heat".tr + tempHeat.substring(5, 7);

    return NovelDetail(title, author, status, finUpdate, imgUrl, introduce, tags, heat, trending, isAnimated);
  }

  static int getMaxNum(String html) {
    final document = parse(html);
    final List<Element> lastPageElements = document.getElementsByClassName("last");
    int pageCount = 0;
    for (final tempElement in lastPageElements) {
      final String textContent = tempElement.text.trim();
      final int? parsedPage = int.tryParse(textContent);
      if (parsedPage != null) {
        pageCount = parsedPage;
      }
    }
    return pageCount;
  }

  static List<RecommendBlock> getRecommend(String html) {
    Document document = parse(html);
    Element? a = document.getElementById("centers");
    List<RecommendBlock> recommendBlockList = [];
    for (int i = 1; i <= 3; i++) {
      List<NovelCover> blockList = [];
      Element? block = a?.getElementsByClassName("block")[i];
      if (block == null) continue;
      String blockTitle = block.getElementsByClassName("blocktitle")[0].text;
      if (i == 1) {
        blockTitle = blockTitle.split("(")[0];
      }
      List<Element> tempBlock1Content = block.querySelectorAll("div[style='float: left;text-align:center;width: 95px; height:155px;overflow:hidden;']");
      for (var j in tempBlock1Content) {
        String title = j.getElementsByTagName("a")[1].text;
        String img = j.getElementsByTagName("img")[0].attributes["src"] ?? "";
        if (!img.startsWith("https")) {
          img = img.replaceFirst("http", "https");
        }
        String url = j.getElementsByTagName("a")[0].attributes["href"] ?? "";
        String aid = url.contains("book/") ? url.substring(url.indexOf("book/") + 5, url.indexOf(".htm")) : "";
        blockList.add(NovelCover(title, img, aid));
      }
      recommendBlockList.add(RecommendBlock(blockTitle, blockList));
    }
    RegExp regex = RegExp(r"^(http|https)://[^\s/$.?#].[^\s]*$");
    for (int i = 2; i <= 3; i++) {
      Element? b = document.querySelectorAll("div.main")[i];
      List<NovelCover> blockList = [];
      String blockTitle = b.querySelector("div.blocktitle")?.text ?? "";
      if (i == 3) {
        blockTitle = blockTitle.split("(")[0];
      }
      List<Element> tempBlock1Content = b.querySelectorAll("div[style='float: left;text-align:center;width: 95px; height:155px;overflow:hidden;']");
      for (var j in tempBlock1Content) {
        try {
          String title = j.getElementsByTagName("a")[1].text;
          String img = j.getElementsByTagName("img")[0].attributes["src"] ?? "";
          if (!regex.hasMatch(img)) throw Exception();
          if (!img.startsWith("https")) {
            img = img.replaceFirst("http", "https");
          }
          String url = j.getElementsByTagName("a")[0].attributes["href"] ?? "";
          String aid = url.contains("book/") ? url.substring(url.indexOf("book/") + 5, url.indexOf(".htm")) : "";
          blockList.add(NovelCover(title, img, aid));
        } catch (e) {
          continue;
        }
      }
      recommendBlockList.add(RecommendBlock(blockTitle, blockList));
    }

    return recommendBlockList;
  }

  static List<CatVolume> getCatalogue(String html) {
    final document = parse(html);

    final table = document.querySelector('table.css');
    if (table == null) return [];

    final rows = table.querySelectorAll('tr');
    final List<CatVolume> volumes = [];

    String? currentVolumeTitle;
    List<CatChapter> currentChapters = [];

    for (var row in rows) {
      final volTd = row.querySelector('td.vcss');
      if (volTd != null) {
        if (currentVolumeTitle != null) {
          volumes.add(CatVolume(title: currentVolumeTitle, chapters: currentChapters));
          currentChapters = [];
        }
        currentVolumeTitle = volTd.text.trim();
        continue;
      }

      final ccssTds = row.querySelectorAll('td.ccss');
      for (var td in ccssTds) {
        final linkEl = td.querySelector('a');
        if (linkEl == null) continue;

        final title = linkEl.text.trim();
        final href = linkEl.attributes['href']?.trim() ?? '';

        if (title.isEmpty || href.isEmpty) continue;

        String cid = '';
        final parts = href.split('&cid=');
        if (parts.length > 1) {
          cid = parts.last;
        }

        currentChapters.add(CatChapter(title: title, cid: cid));
      }
    }

    if (currentVolumeTitle != null) {
      volumes.add(CatVolume(title: currentVolumeTitle, chapters: currentChapters));
    }

    return volumes;
  }

  static List<CommentItem> getComment(String html) {
    final document = parse(html);
    final contentEl = document.getElementById('content');
    if (contentEl == null) {
      throw StateError('Element with id "content" not found');
    }
    final tables = contentEl.getElementsByTagName('table');
    if (tables.length < 3) {
      throw StateError('Expected at least 3 tables inside "content"');
    }
    final targetTable = tables[2];
    final rows = targetTable.getElementsByTagName('tr');
    final comments = <CommentItem>[];
    for (final row in rows) {
      if (row.attributes.containsKey('align')) continue;
      final tds = row.getElementsByTagName('td');
      if (tds.length < 4) continue;
      final a0 = tds[0].querySelector('a');
      var reply = a0?.attributes['href'] ?? '';
      RegExp regExp = RegExp(r"rid=(\d+)");
      RegExpMatch? match = regExp.firstMatch(reply);
      if (match != null) {
        reply = match.group(1)!;
      }
      final contentText = a0?.text.trim() ?? '';
      final viewAndReply = tds[1].text.trim();
      final idx = viewAndReply.indexOf('/');
      final replyCount = idx > 0 ? viewAndReply.substring(0, idx) : '';
      final viewCount = (idx >= 0 && idx + 1 < viewAndReply.length) ? viewAndReply.substring(idx + 1) : '';
      final a2 = tds[2].querySelector('a');
      final userName = a2?.text.trim() ?? '';
      final href2 = a2?.attributes['href'] ?? '';
      final uid = href2.contains('uid=') ? href2.split('uid=').last : '';
      final timeRaw = tds[3].text.trim();
      final time = Util.getDateTime(timeRaw);

      comments.add(CommentItem(rid: reply, content: contentText, replyCount: replyCount, viewCount: viewCount, userName: userName, uid: uid, time: time));
    }

    return comments;
  }

  static List<ReplyItem> getReply(String html) {
    final document = parse(html);
    final Element? a = document.getElementById("content");
    if (a == null) {
      return [];
    }
    final List<Element> b = a.getElementsByTagName("table");
    final List<Element> paddingTables = a.querySelectorAll("table[cellpadding='3']");
    if (paddingTables.length > 1) {
      final Element d = paddingTables[1];
      final Element? lastElement = d.querySelector(".last");
      if (lastElement != null) {}
    }
    final List<ReplyItem> tempR = [];
    int count = 0;
    for (final Element c in b) {
      count++;
      if (count < 4) {
        continue;
      } else if (count == b.length - 1) {
        break;
      }
      final List<Element> tds = c.querySelectorAll("td");
      if (tds.length < 2) {
        continue;
      }
      final Element firstTd = tds[0];
      final Element? userLink = firstTd.querySelector("a");
      String userName = userLink?.text ?? "";
      String uid = "";
      final String? href = userLink?.attributes["href"];
      if (href != null && href.contains("uid=")) {
        final List<String> parts = href.split("uid=");
        if (parts.length > 1) {
          uid = parts[1];
        }
      }
      final Element secondTd = tds[1];
      final List<Element> divsInSecondTd = secondTd.querySelectorAll("div");
      String rawTime = "";
      if (divsInSecondTd.length > 1) {
        final Element timeDiv = divsInSecondTd[1];
        rawTime = timeDiv.text;
        if (rawTime.contains("|")) {
          final int pipeIndex = rawTime.indexOf("|");
          if (pipeIndex > 0) {
            rawTime = rawTime.substring(0, pipeIndex - 1);
          }
        }
      }
      final String time = rawTime;
      String content = "";
      if (divsInSecondTd.length > 2) {
        final Element contentDiv = divsInSecondTd[2];
        content = contentDiv.text;
      }
      final String formattedTime = Util.getDateTime(time.trim());
      tempR.add(ReplyItem(content: content, userName: userName, uid: uid, time: formattedTime));
    }
    return tempR;
  }

  static Bookshelf getBookshelf(String html, int classId) {
    final document = parse(html);

    final content = document.getElementById('content');
    if (content == null) {
      throw StateError('Element with id "content" not found');
    }

    final List<BookshelfNovelInfo> novels = [];
    final rows = content.getElementsByTagName('tr');
    for (final row in rows) {
      if (row.attributes.containsKey('align')) continue;
      final firstTd = row.getElementsByTagName('td').isNotEmpty ? row.getElementsByTagName('td')[0] : null;
      if (firstTd != null && firstTd.classes.contains('foot')) continue;

      final bid = row.getElementsByTagName('td')[0].querySelector('input')?.attributes['value'] ?? '';

      final linkEl = row.getElementsByTagName('td')[1].querySelector('a');
      final bookUrl = linkEl?.attributes['href'] ?? '';
      final title = linkEl?.text.trim() ?? '';

      final aidStart = bookUrl.indexOf('aid=') + 4;
      final aidEnd = bookUrl.indexOf('&', aidStart);
      final aid = aidStart >= 4 && aidEnd > aidStart ? bookUrl.substring(aidStart, aidEnd) : '';

      String imgUrl;
      if (aid.length <= 3) {
        imgUrl = 'https://img.wenku8.com/image/0/$aid/${aid}s.jpg';
      } else {
        imgUrl = 'https://img.wenku8.com/image/${aid[0]}/$aid/${aid}s.jpg';
      }

      novels.add(BookshelfNovelInfo(bid: bid, aid: aid, url: bookUrl, title: title, img: imgUrl));
    }

    final gridtop = content.querySelector('div.gridtop')?.text.trim() ?? '';
    var shelfTitle = gridtop.length > 4 ? gridtop.substring(4) : gridtop;
    shelfTitle = shelfTitle.split('。').first.trim();
    shelfTitle = shelfTitle.length > 3 ? shelfTitle.substring(3) : shelfTitle;

    return Bookshelf(list: novels, classId: classId.toString());
  }

  static String novelVote(String html) {
    Document document = parse(html);
    var blockContent = document.getElementsByClassName("blockcontent");
    if (blockContent.isEmpty) throw Exception();
    var targetDiv = blockContent[0].querySelector("div[style='padding:10px']");
    return targetDiv!.text;
  }

  static UserInfo getUserInfo(String html) {
    Document document = parse(html);
    Element content = document.getElementById('content')!;
    Element tbody = content.querySelector('tbody')!;
    List<Element> rows = tbody.querySelectorAll('tr');
    Element row0 = rows[0];
    String avatar = row0.querySelectorAll('td')[2].querySelector('img')!.attributes['src']!.replaceAll("https", "http");
    String userID = row0.querySelectorAll('td')[1].text.trim();
    String userName = rows[2].querySelectorAll('td')[1].text.trim();
    String userLevel = rows[4].querySelectorAll('td')[1].text.trim();
    String email = rows[7].querySelector('a')!.text.trim();
    String signUpDate = rows[12].querySelectorAll('td')[1].text.trim();
    String contribution = rows[13].querySelectorAll('td')[1].text.trim();
    String experience = rows[14].querySelectorAll('td')[1].text.trim();
    String score = rows[15].querySelectorAll('td')[1].text.trim();
    String maxBookcase = rows[18].querySelectorAll('td')[1].text.trim();
    String maxRecommend = rows[19].querySelectorAll('td')[1].text.trim();
    return UserInfo(
      avatar: avatar,
      uid: userID,
      username: userName,
      userLevel: userLevel,
      email: email,
      registerDate: signUpDate,
      contribution: contribution,
      experience: experience,
      point: score,
      maxBookshelfNum: maxBookcase,
      maxRecommendNum: maxRecommend,
    );
  }

  static bool isError(String html) {
    Document document = parse(html);

    List<Element> elements = document.getElementsByClassName('blocktitle');

    String t;
    try {
      if (elements.isEmpty) throw StateError('No .blocktitle elements found');
      t = elements.first.text;
    } catch (_) {
      return false;
    }

    return t == '出现错误！' || t == '出現錯誤！';
  }

  ///判断搜索结果是否只有一个
  static NovelCover? isSearchResultOnlyOne(String html) {
    try {
      final Document document = parse(html);
      final Element? content = document.getElementById('content');
      if (content == null) return null;
      final List<Element> divs = content.getElementsByTagName('div')[0].querySelectorAll('div[style="margin:0px auto;overflow:hidden;"]');
      if (divs.isEmpty) return null;
      final List<Element> spans = divs[0].getElementsByTagName('span');
      if (spans.length < 2) return null;
      final Element span = spans[1];
      final String? bookHref = span.querySelector('a')?.attributes['href'];
      if (bookHref == null) return null;
      final List<Element> tables = content.getElementsByTagName('table');
      if (tables.isEmpty) return null;
      final Element table0 = tables[0];
      final String title = table0.querySelectorAll('span').first.querySelector('b')?.text.trim() ?? '';
      final String imgUrl = ImageUrlHelper.normalize(content.querySelectorAll('img').first.attributes['src']?.trim() ?? '');
      final int idx = bookHref.indexOf('bid=');
      if (idx == -1) return null;
      final String aid = bookHref.substring(idx + 4);

      return NovelCover(title, imgUrl, aid);
    } catch (e) {
      return null;
    }
  }

  static Content getContent(String html) {
    // 解析HTML并提取核心内容
    Document document = parse(html);
    Element contentElement = document.getElementById('content')!;

    // 提取所有img标签的src属性到List
    List<String> imgSrcList = [];
    List<Element> imgElements = contentElement.querySelectorAll('img');
    for (var img in imgElements) {
      String? src = img.attributes['src'];
      if (src != null && src.isNotEmpty) {
        imgSrcList.add(ImageUrlHelper.normalize(src));
      }
    }

    // 移除指定元素（比如id=contentdp的ul）
    contentElement.querySelectorAll('ul#contentdp').forEach((e) => e.remove());

    // 去除文本首尾的空行（核心处理）
    // 正则说明：^[\n\s]* 匹配开头的所有换行/空白；[\n\s]*$ 匹配结尾的所有换行/空白
    String trimmedText = contentElement.text.replaceAll(RegExp(r'^[\n\s]*|[\n\s]*$'), '');

    // 按空行分割成段落列表（兼容含空格的空行）
    List<String> paragraphs = trimmedText.split(RegExp(r'\n\s*\n'));

    // 处理每个段落，仅第一行加缩进
    List<String> processedParagraphs = paragraphs.map((paragraph) {
      String trimmedPara = paragraph.trim();
      if (trimmedPara.isEmpty) {
        return '';
      }
      List<String> lines = paragraph.split('\n');
      if (lines.isNotEmpty) {
        lines[0] = '   ${lines[0]}'; // 仅首行加3个空格
      }
      return lines.join('\n');
    }).toList();

    // 拼接段落，保留段落间空行，确保最终文本无首尾空行
    String finalText = processedParagraphs.join('\n\n').trim();

    // 从纯文本中移除图片链接
    for (var src in imgSrcList) {
      finalText = finalText.replaceAll(src, '');
    }

    return Content(text: finalText, images: imgSrcList);
  }
}
