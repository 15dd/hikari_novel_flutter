import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../common/log.dart';
import '../../../router/route_path.dart';
import '../../../network/request.dart';

class VerticalReadPage extends StatefulWidget {
  final String text;
  final List<String> images;
  final int initialOffset;
  final EdgeInsets padding;
  final TextStyle style;
  final int paraSpacing;
  final int paraIndent;
  final Function(double position, double max) onScroll;

  const VerticalReadPage(
    this.text,
    this.images, {
    required this.initialOffset,
    required this.padding,
    required this.style,
    required this.paraSpacing,
    required this.paraIndent,
    required this.onScroll,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => VerticalReadPageState();
}

class VerticalReadPageState extends State<VerticalReadPage> {
  late ScrollController controller;
  late List<ReaderItem> _items;

  bool _didRestorePosition = false;

  String text = "";
  List<String> images = [];
  TextStyle textStyle = TextStyle();
  EdgeInsets padding = EdgeInsets.zero;
  late int paraIndent;
  late int paraSpacing;

  late String _lastLayoutSig;

  @override
  void initState() {
    super.initState();
    _lastLayoutSig = _layoutSignature();
    _initController();
    resetPage();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double get currentPositionPixels => controller.position.pixels;

  double get maxPositionPixels => controller.position.maxScrollExtent;

  void _initController() {
    controller = ScrollController();
    controller.addListener(_onScroll);
  }

  //滚动监听
  void _onScroll() {
    if (!controller.hasClients) return;
    if (maxPositionPixels <= 0) return;

    widget.onScroll(currentPositionPixels, maxPositionPixels);
  }

  //初始位置恢复
  void _restoreInitialPosition() {
    if (_didRestorePosition) return;
    if (!controller.hasClients) return;

    final position = controller.position;

    if (!position.hasContentDimensions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreInitialPosition();
      });
      return;
    }

    double targetOffset = widget.initialOffset.toDouble();
    targetOffset = targetOffset.clamp(0, position.maxScrollExtent);

    controller.jumpTo(targetOffset);

    _didRestorePosition = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //强制保存一次阅读进度
      if (maxPositionPixels >= 0) {
        widget.onScroll(currentPositionPixels, maxPositionPixels);
      }
    });
  }

  /// 进度跳转
  /// - [value] 范围为0-100的值
  void jumpToProgress(double value) {
    if (!controller.hasClients) return;

    double targetOffset = maxPositionPixels * (value / 100.0);

    targetOffset = targetOffset.clamp(0, maxPositionPixels);

    controller.jumpTo(targetOffset);
  }

  void resetPage() {
    text = widget.text;
    textStyle = widget.style;
    images = List<String>.from(widget.images); //转换为纯净的List<String>
    padding = widget.padding;
    paraIndent = widget.paraIndent;
    paraSpacing = widget.paraSpacing;
    if (text.isEmpty && images.isEmpty) {
      setState(() {});
      return;
    }

    _splitItems();
  }

  @override
  void didUpdateWidget(covariant VerticalReadPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    //这里比较排版几何参数（fontSize, textStyle）是否有变化
    //这里不能使用"widget.xxx != oldWidget.xxx"，这是在比较对象，而不是比较其中的参数。比如深浅模式切换导致页面重建，会重建TextStyle对象实例，最终误判
    final newSig = _layoutSignature();
    if (newSig != _lastLayoutSig) {
      _lastLayoutSig = newSig;
      resetPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreInitialPosition();
    });

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, index) {
              final item = _items[index];

              switch (item.type) {
                case ReaderItemType.text:
                  return _buildText(item.content);
                case ReaderItemType.image:
                  return _buildImage(item.content, item.index!);
              }
            }, childCount: _items.length),
          ),
        ),
      ],
    );
  }

  Widget _buildText(String content) {
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(bottom: paraSpacing.toDouble()),
        child: RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              WidgetSpan(
                child: SizedBox(width: textStyle.fontSize! * paraIndent), //按汉字宽度缩进
              ),
              TextSpan(text: content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String url, int index) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: GestureDetector(
          onDoubleTap: () => Get.toNamed(RoutePath.photo, arguments: {"gallery_mode": true, "list": widget.images, "index": index}),
          onLongPress: () => Get.toNamed(RoutePath.photo, arguments: {"gallery_mode": true, "list": widget.images, "index": index}),
          child: CachedNetworkImage(
            width: double.infinity,
            imageUrl: url,
            httpHeaders: Request.userAgent,
            fit: BoxFit.fitWidth,
            progressIndicatorBuilder: (context, url, progress) => Center(child: CircularProgressIndicator(value: progress.progress)),
            errorWidget: (context, url, error) => Column(children: [const Icon(Icons.error_outline), Text(error.toString())]),
          ),
        ),
      ),
    );
  }

  void _splitItems() {
    final paragraphs = widget.text.split('\n\n').where((e) => e.trim().isNotEmpty);

    _items = [];

    for (var para in paragraphs) {
      _items.add(ReaderItem.text(para.trimLeft()));
    }

    for (int i = 0; i < widget.images.length; i++) {
      _items.add(ReaderItem.image(widget.images[i], i));
    }
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
      widget.paraIndent,
      widget.paraSpacing,
    ].join("|");
  }
}

enum ReaderItemType { text, image }

class ReaderItem {
  final ReaderItemType type;
  final String content;
  int? index;

  ReaderItem.text(this.content) : type = ReaderItemType.text;

  ReaderItem.image(this.content, this.index) : type = ReaderItemType.image;
}
