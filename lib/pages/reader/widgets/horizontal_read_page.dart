import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../network/request.dart';

class HorizontalReadPage extends StatefulWidget {
  final String text;
  final List<String> images;
  final int initIndex;
  final EdgeInsets padding;
  final TextStyle style;
  final PageController controller;
  final bool reverse;
  final bool isDualPage;
  final double dualPageSpacing;
  final Function(int index, int max) onPageChanged;
  final Function(int index) onViewImage;

  const HorizontalReadPage(
    this.text,
    this.images, {
    required this.initIndex,
    required this.padding,
    required this.style,
    required this.controller,
    this.reverse = false,
    required this.isDualPage,
    required this.dualPageSpacing,
    required this.onPageChanged,
    required this.onViewImage,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _HorizontalReadPageState();
}

class _HorizontalReadPageState extends State<HorizontalReadPage> with WidgetsBindingObserver {
  List<Page> pages = [];
  String text = "";
  List<String> images = [];

  TextStyle textStyle = const TextStyle();
  double fontHeight = 16.0;
  EdgeInsets padding = EdgeInsets.zero;
  late Size lastSize;

  double pageWidth = 0;
  double pageHeight = 0;
  int index = 0; //HorizontalReadPage内部的页面，与PageController的页面无关

  late String _lastLayoutSig;

  @override
  void initState() {
    super.initState();
    lastSize = Get.size;
    _lastLayoutSig = _layoutSignature();
    WidgetsBinding.instance.addObserver(this);
    resetPage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (lastSize != Get.size) {
      lastSize = Get.size;
      resetPage();
    }
  }

  void resetPage() {
    text = widget.text;
    textStyle = widget.style;
    images = List<String>.from(widget.images); //转换为纯净的List<String>
    padding = widget.padding;
    pageWidth = (Get.width - padding.left - padding.right).floorToDouble();
    pageWidth = widget.isDualPage ? (pageWidth - widget.dualPageSpacing * 2) / 2 : pageWidth;
    pageHeight = Get.height - padding.top - padding.bottom;
    if (text.isEmpty && images.isEmpty) {
      index = 0;
      setState(() {
        pages = [];
      });
      return;
    }
    initPage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPageChanged(index, _pageCount()); //页面加载完成时，提醒保存进度
    });
  }

  @override
  void didUpdateWidget(covariant HorizontalReadPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    //这里比较排版几何参数（fontSize, textStyle）是否有变化
    //这里不能使用"widget.xxx != oldWidget.xxx"，这是在比较对象，而不是比较其中的参数。比如深浅模式切换导致页面重建，会重建TextStyle对象实例，最终误判
    final newSig = _layoutSignature();
    if (newSig != _lastLayoutSig) {
      _lastLayoutSig = newSig;
      if (widget.text != oldWidget.text && listEquals(widget.images, oldWidget.images)) { //判断章节是否切换
        index = 0;
        setState(() {
          pages = [];
        });
      }
      resetPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      reverse: widget.reverse,
      itemCount: _pageCount(),
      onPageChanged: (v) {
        index = v;
        widget.onPageChanged(v, _pageCount());
      },
      itemBuilder: (_, i) => _buildPage(i),
    );
  }

  int _pageCount() {
    if (widget.isDualPage) {
      if (pages.length % 2 == 0) {
        return (pages.length / 2).toInt();
      } else {
        return ((pages.length + 1) / 2).toInt();
      }
    } else {
      return pages.length;
    }
  }

  Widget _buildPage(int index) {
    if (widget.isDualPage) {
      return _buildDualPage(index);
    } else {
      if (pages[index] is TextPage) {
        return _buildSingleText(index);
      } else {
        return _buildImage(index);
      }
    }
  }

  Widget _buildDualPage(int i) {
    int firstIndex = i * 2;
    int secondIndex = firstIndex + 1;

    return Padding(
      padding: padding,
      child: SizedBox(
        height: pageHeight,
        child: widget.reverse
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: widget.dualPageSpacing),
                      child: Builder(
                        builder: (_) {
                          if (secondIndex >= pages.length) {
                            return SizedBox.shrink();
                          } else if (pages[secondIndex] is TextPage) {
                            return _buildDualSideText(secondIndex);
                          } else {
                            return _buildImage(secondIndex);
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: widget.dualPageSpacing), //模拟书脊间隙
                      child: Builder(
                        builder: (_) {
                          if (firstIndex >= pages.length) {
                            return SizedBox.shrink();
                          } else if (pages[firstIndex] is TextPage) {
                            return _buildDualSideText(firstIndex);
                          } else {
                            return _buildImage(firstIndex);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: widget.dualPageSpacing), //模拟书脊间隙
                      child: Builder(
                        builder: (_) {
                          if (firstIndex >= pages.length) {
                            return SizedBox.shrink();
                          } else if (pages[firstIndex] is TextPage) {
                            return _buildDualSideText(firstIndex);
                          } else {
                            return _buildImage(firstIndex);
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: widget.dualPageSpacing),
                      child: Builder(
                        builder: (_) {
                          if (secondIndex >= pages.length) {
                            return SizedBox.shrink();
                          } else if (pages[secondIndex] is TextPage) {
                            return _buildDualSideText(secondIndex);
                          } else {
                            return _buildImage(secondIndex);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSingleText(int index) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: pageHeight,
        child: CustomPaint(
          painter: NovelTextPainter((pages[index] as TextPage).texts, style: widget.style, fontHeight: fontHeight),
        ),
      ),
    );
  }

  Widget _buildDualSideText(int index) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: pageHeight,
          width: constraints.maxWidth,
          child: CustomPaint(
            painter: NovelTextPainter((pages[index] as TextPage).texts, style: widget.style, fontHeight: fontHeight),
          ),
        );
      },
    );
  }

  Widget _buildImage(int imageIndex) {
    return Center(
      child: GestureDetector(
        onDoubleTap: () => widget.onViewImage(imageIndex),
        onLongPress: () => widget.onViewImage(imageIndex),
        child: CachedNetworkImage(
          imageUrl: (pages[imageIndex] as ImagePage).url,
          httpHeaders: Request.userAgent,
          fit: BoxFit.contain,
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
          errorWidget: (context, url, error) => Center(child: Column(children: [Icon(Icons.error_outline), Text(error.toString())])),
        ),
      ),
    );
  }

  void initPage() async {
    double fontSize = textStyle.fontSize!;
    double lineHeight = textStyle.height!;

    //计算出各类文字的字体大小
    //至于为什么不固定大小是因为主文字大小和行高会变动，需要重新计算
    Size chineseCharSize = calcFontSize("中", fontSize: fontSize, lineHeight: lineHeight);
    fontHeight = chineseCharSize.height; //以中文的高度为准，毕竟是中文阅读器
    Size englishCharSize = calcFontSize("e", fontSize: fontSize, lineHeight: lineHeight);
    Size symbolCharSize = calcFontSize(",", fontSize: fontSize, lineHeight: lineHeight);
    Size spaceCharSize = calcFontSize(" ", fontSize: fontSize, lineHeight: lineHeight);

    //计算一页中的最大行数
    int maxLine = (pageHeight / chineseCharSize.height).floor(); //去小数

    var pages = await compute(
      splitText,
      ComputeParameter(
        rawText: text,
        rawImage: images,
        fontSize: fontSize,
        width: pageWidth,
        maxLine: maxLine,
        lineHeight: lineHeight,
        chineseWidth: chineseCharSize.width,
        englishWidth: englishCharSize.width,
        symbolWidth: symbolCharSize.width,
        spaceWidth: spaceCharSize.width,
      ),
    );

    this.pages = pages;
    widget.onPageChanged(index, _pageCount());

    setState(() {}); //刷新UI

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.jumpToPage(widget.initIndex);
    });
  }

  static List<Page> splitText(ComputeParameter parameter) {
    var str = parameter.rawText;
    var img = parameter.rawImage;

    List<Page> pages = [];

    if (str.isNotEmpty) {
      //定义正则表达式（匹配中文字符、英文单词、符号、全角符号、数字串）
      //RegExp reg = RegExp(r"([\u4e00-\u9fa5]|\b\w+\b|\x20|　|\S|\p{Han}|\n)");
      RegExp reg = RegExp(r"([^\x00-\xff]|\b\w+\b|\p{P}|\x20|\S|\u3000|\n)");

      //使用正则表达式分割字符串
      List<String> resultList = reg.allMatches(str).map((match) => match.group(0) ?? "").toList();

      List<CharInfo> chars = [];
      final chineseExp = RegExp(r"[^\x00-\xff]");
      final wordExp = RegExp(r"\w+");
      final symbolExp = RegExp(r"\p{P}");
      final newLineExp = RegExp(r"\n");

      for (var item in resultList) {
        if (chineseExp.hasMatch(item)) {
          chars.add(CharInfo(text: item, width: parameter.chineseWidth, type: CharType.chinese));
          continue;
        }
        if (wordExp.hasMatch(item)) {
          chars.add(CharInfo(text: item, width: parameter.englishWidth * item.length, type: CharType.word));
          continue;
        }
        if (newLineExp.hasMatch(item)) {
          chars.add(CharInfo(text: "", width: 0, type: CharType.newline));
          continue;
        }
        if (item == " ") {
          chars.add(CharInfo(text: item, width: parameter.spaceWidth, type: CharType.symbol));
          continue;
        }
        if (symbolExp.hasMatch(item)) {
          chars.add(CharInfo(text: item, width: parameter.symbolWidth, type: CharType.symbol));
          continue;
        }
        chars.add(CharInfo(text: item, width: parameter.symbolWidth, type: CharType.symbol));
      }

      List<String> currentTextPage = [];
      String rowText = "";
      double currentRowWidth = 0;

      for (var item in chars) {
        //是否超出了最大行数
        if (currentTextPage.length >= parameter.maxLine) {
          pages.add(TextPage(pages.length, currentTextPage));
          currentTextPage = [];
        }
        //新行
        if (item.type == CharType.newline) {
          currentTextPage.add(rowText);
          rowText = "";
          currentRowWidth = 0;
          continue;
        }
        //是否超出了最大宽度
        if ((currentRowWidth + item.width) > parameter.width) {
          currentTextPage.add(rowText);
          rowText = "";
          currentRowWidth = 0;
        }
        rowText += item.text;
        currentRowWidth += item.width;
      }

      currentTextPage.add(rowText);
      pages.add(TextPage(pages.length, currentTextPage));
      final first = pages.first as TextPage;
      if (pages.length == 1 && first.texts.length == 1 && first.texts.first.isEmpty) {
        return [];
      }
    }

    //添加图片
    if (img.isNotEmpty) {
      for (var i in img) {
        pages.add(ImagePage(pages.length, i));
      }
    }

    return pages;
  }

  Size calcFontSize(String text, {required double fontSize, required double lineHeight}) {
    TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, height: lineHeight),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    painter.layout(maxWidth: 200);
    return painter.size;
  }

  //排版几何参数的签名
  String _layoutSignature() {
    final s = widget.style;
    final p = widget.padding;

    return [
      widget.text.length,
      widget.images.length,
      s.fontSize,
      s.height,
      s.letterSpacing,
      s.wordSpacing,
      s.color?.toARGB32(),
      p.left,
      p.right,
      p.top,
      p.bottom,
    ].join("|");
  }
}

enum CharType {
  //中文及全角符号
  chinese,
  //单词
  word,
  //数字
  number,
  //符号
  symbol,
  //换行符
  newline,
}

class CharInfo {
  CharType type;
  String text;
  double width;

  CharInfo({required this.text, required this.width, required this.type});

  @override
  String toString() {
    return "($type,$width,$text)";
  }
}

class ComputeParameter {
  String rawText;
  List<String> rawImage;
  double width;
  double fontSize;
  double lineHeight;
  int maxLine;
  double chineseWidth;
  double englishWidth;
  double symbolWidth;
  double spaceWidth;

  ComputeParameter({
    required this.rawText,
    required this.rawImage,
    required this.fontSize,
    required this.width,
    required this.maxLine,
    required this.lineHeight,
    required this.chineseWidth,
    required this.englishWidth,
    required this.symbolWidth,
    required this.spaceWidth,
  });
}

class NovelTextPainter extends CustomPainter {
  final TextStyle style;
  final double fontHeight;
  final List<String> text;

  NovelTextPainter(this.text, {required this.style, required this.fontHeight});

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    for (var item in text) {
      TextSpan textSpan = TextSpan(text: item, style: style);

      final textPainter = TextPainter(text: textSpan, maxLines: 1, textAlign: TextAlign.justify, textDirection: TextDirection.ltr);
      textPainter.layout(maxWidth: size.width);

      final offset = Offset(0, i * fontHeight);
      textPainter.paint(canvas, offset);

      i++;
    }
  }

  @override
  bool shouldRepaint(covariant NovelTextPainter oldDelegate) {
    return oldDelegate.style != style || oldDelegate.text != text || oldDelegate.fontHeight != fontHeight;
  }
}

abstract class Page {
  final int index;

  Page(this.index);
}

class TextPage extends Page {
  final List<String> texts;

  TextPage(super.index, this.texts);
}

class ImagePage extends Page {
  final String url;

  ImagePage(super.index, this.url);
}