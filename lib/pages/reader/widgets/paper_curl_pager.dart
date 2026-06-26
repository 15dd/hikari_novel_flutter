import 'dart:math' as math;

import 'package:flutter/material.dart';

class PaperCurlPagerController {
  void Function(int target)? _jumpTo;

  void _bind(void Function(int target) jumpTo) {
    _jumpTo = jumpTo;
  }

  void _unbind(void Function(int target) jumpTo) {
    if (_jumpTo == jumpTo) {
      _jumpTo = null;
    }
  }

  void jumpToPage(int target) {
    _jumpTo?.call(target);
  }
}

class PaperCurlPager extends StatefulWidget {
  const PaperCurlPager.builder({
    super.key,
    this.controller,
    required this.pageCount,
    required this.pageBuilder,
    required this.initialIndex,
    this.isPageInteractive,
    this.reverse = false,
    this.duration = const Duration(milliseconds: 520),
    this.animationEnabled = true,
    this.backgroundColor,
    this.backsideColor,
    this.onIndexChanged,
    this.onCenterTap,
    this.onReachStart,
    this.onReachEnd,
    this.edgeTapWidthFactor = 0.28,
  }) : assert(pageCount >= 0);

  final PaperCurlPagerController? controller;
  final int pageCount;
  final IndexedWidgetBuilder pageBuilder;
  final int initialIndex;
  final bool Function(int index)? isPageInteractive;
  final bool reverse;
  final Duration duration;
  final bool animationEnabled;
  final Color? backgroundColor;
  final Color? backsideColor;
  final ValueChanged<int>? onIndexChanged;
  final VoidCallback? onCenterTap;
  final VoidCallback? onReachStart;
  final VoidCallback? onReachEnd;
  final double edgeTapWidthFactor;

  @override
  State<PaperCurlPager> createState() => _PaperCurlPagerState();
}

class _PaperCurlPagerState extends State<PaperCurlPager>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Size _size = Size.zero;
  Offset _downPos = Offset.zero;
  Offset _dragPos = Offset.zero;
  Offset _animStartPos = Offset.zero;
  Offset _animEndPos = Offset.zero;
  bool _fromTop = false;
  bool _fromSide = false;
  bool _isDragging = false;
  bool _isAnimating = false;
  bool _turningForward = true;
  int _index = 0;
  int? _targetIndex;
  double _progress = 0;
  double _dragDelta = 0;
  Curve _releaseCurve = Curves.easeInOutCubic;

  int get _lastIndex => widget.pageCount <= 0 ? 0 : widget.pageCount - 1;

  bool get _currentPageInteractive =>
      widget.isPageInteractive?.call(_index) ?? false;

  bool get _canGoForward =>
      widget.pageCount > 0 && _targetForDirection(true) != _index;

  bool get _canGoBackward =>
      widget.pageCount > 0 && _targetForDirection(false) != _index;

  @override
  void initState() {
    super.initState();
    _index = _safeIndex(widget.initialIndex);
    _controller = AnimationController(vsync: this, duration: _effectiveDuration)
      ..addListener(_handleTick)
      ..addStatusListener(_handleStatus);
    widget.controller?._bind(_jumpToExternal);
  }

  @override
  void didUpdateWidget(covariant PaperCurlPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._unbind(_jumpToExternal);
      widget.controller?._bind(_jumpToExternal);
    }
    final newDuration = _effectiveDuration;
    if (_controller.duration != newDuration) {
      _controller.duration = newDuration;
    }
    final safeInitial = _safeIndex(widget.initialIndex);
    final shouldReset =
        widget.pageCount != oldWidget.pageCount || safeInitial != _index;
    if (!_isDragging && !_isAnimating && shouldReset) {
      _index = safeInitial;
      _resetGestureState(notify: false);
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind(_jumpToExternal);
    _controller.dispose();
    super.dispose();
  }

  Duration get _effectiveDuration => widget.animationEnabled
      ? widget.duration
      : const Duration(milliseconds: 1);

  int _safeIndex(int raw) {
    if (widget.pageCount <= 0) return 0;
    return raw.clamp(0, widget.pageCount - 1);
  }

  int _targetForDirection(bool forward) {
    if (widget.pageCount <= 0) return 0;
    final delta = _nextForOpening(forward) ? 1 : -1;
    return (_index + delta).clamp(0, _lastIndex);
  }

  void _notifyReachedBoundary(bool forward) {
    if (_nextForOpening(forward)) {
      widget.onReachEnd?.call();
    } else {
      widget.onReachStart?.call();
    }
  }

  bool _nextForOpening(bool opensFromRight) =>
      widget.reverse ? !opensFromRight : opensFromRight;

  void _jumpToExternal(int target) {
    final safeTarget = _safeIndex(target);
    if (_index == safeTarget && !_isAnimating && !_isDragging) {
      return;
    }
    _controller.stop();
    _index = safeTarget;
    _resetGestureState();
    widget.onIndexChanged?.call(_index);
  }

  void _resetGestureState({bool notify = true}) {
    _isDragging = false;
    _isAnimating = false;
    _turningForward = true;
    _fromSide = false;
    _targetIndex = null;
    _progress = 0;
    _dragDelta = 0;
    _downPos = Offset.zero;
    _dragPos = Offset.zero;
    _animStartPos = Offset.zero;
    _animEndPos = Offset.zero;
    if (notify && mounted) {
      setState(() {});
    }
  }

  void _handleTick() {
    if (!_isAnimating) return;
    final t = _releaseCurve.transform(_controller.value);
    setState(() {
      _dragPos = Offset(
        _lerp(_animStartPos.dx, _animEndPos.dx, t),
        _lerp(_animStartPos.dy, _animEndPos.dy, t),
      );
      _dragDelta = _dragPos.dx - _downPos.dx;
      _progress = _progressForCurrentDrag();
    });
  }

  void _handleStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final didComplete =
        _targetIndex != null &&
        (_turningForward
            ? _dragPos.dx <= 0.5
            : _dragPos.dx >= _size.width - 0.5);
    if (didComplete) {
      _index = _targetIndex!;
      widget.onIndexChanged?.call(_index);
    }
    _resetGestureState();
  }

  void _ensureSize(Size size) {
    if (_size == size) return;
    _size = size;
  }

  Offset _logicalOffset(Offset physical) {
    return physical;
  }

  void _startGesture({required bool forward, required Offset localPos}) {
    _turningForward = forward;
    _targetIndex = _targetForDirection(forward);
    _fromSide =
        localPos.dy > _size.height / 3 && localPos.dy < _size.height * 2 / 3;
    _fromTop = !_fromSide && localPos.dy <= (_size.height / 2);
    _isDragging = true;
    _isAnimating = false;
    _downPos = localPos;
    _dragPos = localPos;
    _dragDelta = 0;
    _progress = 0;
  }

  double _progressForCurrentDrag() {
    if (_size.width <= 0) return 0;
    return (_dragDelta.abs() / _size.width).clamp(0.0, 1.0);
  }

  void _updateDrag(Offset localPos) {
    _dragPos = Offset(
      localPos.dx.clamp(0.0, _size.width),
      localPos.dy.clamp(0.0, _size.height),
    );
    _dragDelta = _dragPos.dx - _downPos.dx;
    _progress = _progressForCurrentDrag();
  }

  Offset _releaseTarget(bool complete) {
    final targetX = complete
        ? (_fromSide
              ? (_turningForward ? -_size.width : _size.width * 2)
              : (_turningForward ? -_size.width * 0.16 : _size.width * 1.16))
        : _downPos.dx;
    final targetY = complete
        ? (_fromSide
              ? _downPos.dy
                    .clamp(0.1, math.max(0.1, _size.height - 0.1))
                    .toDouble()
              : (_fromTop ? 0.1 : math.max(0.1, _size.height - 0.1)))
        : _downPos.dy;
    return Offset(targetX, targetY);
  }

  void _animateRelease({required bool complete, required Curve curve}) {
    _isDragging = false;
    _isAnimating = true;
    _releaseCurve = curve;
    _animStartPos = _dragPos;
    _animEndPos = _releaseTarget(complete);
    _controller.forward(from: 0);
  }

  void _animateTapTurn(bool forward, {required bool fromTop}) {
    if ((forward && !_canGoForward) || (!forward && !_canGoBackward)) {
      return;
    }
    final startX = forward ? _size.width * 0.92 : _size.width * 0.08;
    final startY = fromTop ? _size.height * 0.18 : _size.height * 0.82;
    _startGesture(forward: forward, localPos: Offset(startX, startY));
    _dragPos = Offset(
      forward ? _size.width * 0.76 : _size.width * 0.24,
      startY,
    );
    _dragDelta = _dragPos.dx - _downPos.dx;
    _progress = _progressForCurrentDrag();
    _animateRelease(complete: true, curve: Curves.easeInOutCubic);
  }

  void _handleTap(TapUpDetails details) {
    if (_size.width <= 0 || _size.height <= 0) return;
    if (_currentPageInteractive) return;
    final pos = _logicalOffset(details.localPosition);
    final left = _size.width * widget.edgeTapWidthFactor;
    final right = _size.width * (1 - widget.edgeTapWidthFactor);
    final fromTop = pos.dy <= (_size.height / 2);
    if (pos.dx <= left) {
      final opensFromRight = widget.reverse;
      if ((opensFromRight && !_canGoForward) ||
          (!opensFromRight && !_canGoBackward)) {
        _notifyReachedBoundary(opensFromRight);
      } else {
        setState(() {
          _animateTapTurn(opensFromRight, fromTop: fromTop);
        });
      }
      return;
    }
    if (pos.dx >= right) {
      final opensFromRight = !widget.reverse;
      if ((opensFromRight && !_canGoForward) ||
          (!opensFromRight && !_canGoBackward)) {
        _notifyReachedBoundary(opensFromRight);
      } else {
        setState(() {
          _animateTapTurn(opensFromRight, fromTop: fromTop);
        });
      }
      return;
    }
    widget.onCenterTap?.call();
  }

  void _handlePanDown(DragDownDetails details) {
    if (_size.width <= 0 || _size.height <= 0) return;
    _controller.stop();
    _isAnimating = false;
    final localPos = _logicalOffset(details.localPosition);
    _downPos = localPos;
    _dragPos = localPos;
    _dragDelta = 0;
    _progress = 0;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.pageCount <= 0 || _size.width <= 0 || _size.height <= 0) {
      return;
    }
    final localPos = _logicalOffset(details.localPosition);
    if (!_isDragging) {
      final delta = localPos - _downPos;
      if (delta.distanceSquared < 16) {
        return;
      }
      final forward = delta.dx < 0;
      if (forward && !_canGoForward) {
        _notifyReachedBoundary(true);
        return;
      }
      if (!forward && !_canGoBackward) {
        _notifyReachedBoundary(false);
        return;
      }
      setState(() {
        _startGesture(forward: forward, localPos: _downPos);
        _updateDrag(localPos);
      });
      return;
    }
    setState(() {
      _updateDrag(localPos);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final flingForward = velocity < -500;
    final flingBackward = velocity > 500;
    final shouldComplete = _turningForward
        ? (_progress > 0.2 || (_progress > 0.05 && flingForward))
        : (_progress > 0.2 || (_progress > 0.05 && flingBackward));
    _animateRelease(
      complete: shouldComplete,
      curve: shouldComplete ? Curves.easeInOutCubic : Curves.easeOutQuart,
    );
  }

  Widget _pageAt(int index, Map<int, Widget> pageCache) {
    if (widget.pageCount <= 0 || index < 0 || index >= widget.pageCount) {
      return const SizedBox.shrink();
    }
    final background =
        widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final page = pageCache.putIfAbsent(
      index,
      () => widget.pageBuilder(context, index),
    );
    return ColoredBox(
      color: background,
      child: SizedBox.expand(child: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _ensureSize(Size(constraints.maxWidth, constraints.maxHeight));
        final background =
            widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
        final backside =
            widget.backsideColor ??
            Color.lerp(
              background,
              Colors.black,
              Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.08,
            )!;
        final showTurn =
            (_isDragging || _isAnimating) &&
            _targetIndex != null &&
            _progress > 0.0001;
        final pageCache = <int, Widget>{};
        final underIndex = showTurn ? _targetIndex! : _index;
        final fold = _FoldGeometry.fromDrag(
          size: _size,
          dragPos: _dragPos,
          progress: _progress,
          forward: _turningForward,
          fromTop: _fromTop,
          fromSide: _fromSide,
        );

        Widget child = DecoratedBox(
          decoration: BoxDecoration(color: background),
          child: ClipRect(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _handleTap,
              onPanDown: _handlePanDown,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: background, child: const SizedBox.expand()),
                  if (showTurn)
                    ClipPath(
                      clipper: _NextPageClipper(fold),
                      child: _pageAt(underIndex, pageCache),
                    )
                  else
                    _pageAt(underIndex, pageCache),
                  if (showTurn)
                    CustomPaint(
                      painter: _UnderPageShadowPainter(
                        geometry: fold,
                        shadowColor: _alpha(
                          Colors.black,
                          Theme.of(context).brightness == Brightness.dark
                              ? 0.34
                              : 0.22,
                        ),
                      ),
                    ),
                  if (showTurn)
                    ClipPath(
                      clipper: _CurrentPageClipper(fold),
                      child: _pageAt(_index, pageCache),
                    )
                  else
                    _pageAt(_index, pageCache),
                  if (showTurn)
                    IgnorePointer(
                      child: ClipPath(
                        clipper: _FoldBackClipper(fold),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform(
                              transform: fold.backTransform,
                              filterQuality: FilterQuality.low,
                              child: _pageAt(_index, pageCache),
                            ),
                            ColoredBox(
                              color: _alpha(
                                backside,
                                Theme.of(context).brightness == Brightness.dark
                                    ? 0.64
                                    : 0.52,
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: _turningForward
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  end: _turningForward
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                                  colors: [
                                    Color.lerp(
                                      backside,
                                      background,
                                      0.18,
                                    )!.withValues(alpha: 0.84),
                                    Color.lerp(
                                      backside,
                                      background,
                                      0.62,
                                    )!.withValues(alpha: 0.76),
                                    Color.lerp(
                                      background,
                                      Colors.white,
                                      0.14,
                                    )!.withValues(alpha: 0.40),
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );

        return child;
      },
    );
  }
}

class _FoldGeometry {
  _FoldGeometry({
    required this.size,
    required this.progress,
    required this.forward,
    required this.fromTop,
    required this.fromSide,
    required this.touch,
    required this.corner,
  }) {
    _calculate();
  }

  final Size size;
  final double progress;
  final bool forward;
  final bool fromTop;
  final bool fromSide;
  final Offset touch;
  final Offset corner;

  late Offset bezierStart1;
  late Offset bezierControl1;
  late Offset bezierVertex1;
  late Offset bezierEnd1;
  late Offset bezierStart2;
  late Offset bezierControl2;
  late Offset bezierVertex2;
  late Offset bezierEnd2;
  late Offset adjustedTouch;
  late double touchToCornerDistance;
  late bool isRightTopOrLeftBottom;
  late Matrix4 backTransform;

  static _FoldGeometry fromDrag({
    required Size size,
    required Offset dragPos,
    required double progress,
    required bool forward,
    required bool fromTop,
    required bool fromSide,
  }) {
    final safeWidth = size.width <= 0 ? 1.0 : size.width;
    final safeHeight = size.height <= 0 ? 1.0 : size.height;
    final safeTouchY = dragPos.dy
        .clamp(0.1, math.max(0.1, safeHeight - 0.1))
        .toDouble();
    return _FoldGeometry(
      size: size,
      progress: progress.clamp(0.0, 1.0),
      forward: forward,
      fromTop: fromTop,
      fromSide: fromSide,
      touch: Offset(
        dragPos.dx.clamp(-safeWidth, safeWidth * 2).toDouble(),
        safeTouchY,
      ),
      corner: Offset(
        forward ? safeWidth : 0.0,
        fromSide ? safeTouchY : (fromTop ? 0.0 : safeHeight),
      ),
    );
  }

  double get maxLength =>
      math.sqrt(size.width * size.width + size.height * size.height);

  double get foldShadowExtent => math.max(18.0, touchToCornerDistance / 4.0);

  double get shadowAngle =>
      math.atan2(bezierControl1.dx - corner.dx, bezierControl2.dy - corner.dy);

  Path get turnedPagePath {
    if (fromSide) {
      return _sideFoldBackPath;
    }
    return Path()
      ..moveTo(bezierStart1.dx, bezierStart1.dy)
      ..quadraticBezierTo(
        bezierControl1.dx,
        bezierControl1.dy,
        bezierEnd1.dx,
        bezierEnd1.dy,
      )
      ..lineTo(adjustedTouch.dx, adjustedTouch.dy)
      ..lineTo(bezierEnd2.dx, bezierEnd2.dy)
      ..quadraticBezierTo(
        bezierControl2.dx,
        bezierControl2.dy,
        bezierStart2.dx,
        bezierStart2.dy,
      )
      ..lineTo(corner.dx, corner.dy)
      ..close();
  }

  Path get currentPagePath {
    if (fromSide) {
      final creaseX = _sideCreaseX;
      if (forward) {
        return Path()..addRect(Rect.fromLTWH(0, 0, creaseX, size.height));
      }
      return Path()
        ..addRect(Rect.fromLTWH(creaseX, 0, size.width - creaseX, size.height));
    }
    return Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      turnedPagePath,
    );
  }

  Path get nextPagePath {
    if (fromSide) {
      final creaseX = _sideCreaseX;
      if (forward) {
        return Path()..addRect(
          Rect.fromLTWH(creaseX, 0, size.width - creaseX, size.height),
        );
      }
      return Path()..addRect(Rect.fromLTWH(0, 0, creaseX, size.height));
    }
    return Path()
      ..moveTo(bezierStart1.dx, bezierStart1.dy)
      ..lineTo(bezierVertex1.dx, bezierVertex1.dy)
      ..lineTo(bezierVertex2.dx, bezierVertex2.dy)
      ..lineTo(bezierStart2.dx, bezierStart2.dy)
      ..lineTo(corner.dx, corner.dy)
      ..close();
  }

  Path get backPath {
    if (fromSide) return _sideFoldBackPath;
    return Path()
      ..moveTo(bezierVertex2.dx, bezierVertex2.dy)
      ..lineTo(bezierVertex1.dx, bezierVertex1.dy)
      ..lineTo(bezierEnd1.dx, bezierEnd1.dy)
      ..lineTo(adjustedTouch.dx, adjustedTouch.dy)
      ..lineTo(bezierEnd2.dx, bezierEnd2.dy)
      ..close();
  }

  Path get backVisiblePath {
    if (fromSide) return _sideFoldBackPath;
    return Path.combine(PathOperation.intersect, turnedPagePath, backPath);
  }

  void _calculate() {
    final width = math.max(1.0, size.width);
    final height = math.max(1.0, size.height);
    if (fromSide) {
      adjustedTouch = Offset(
        touch.dx.clamp(-width, width * 2),
        touch.dy.clamp(0.1, math.max(0.1, height - 0.1)),
      );
      final creaseX = _sideCreaseX;
      final visibleTouchX = _sideVisibleTouchX;
      final edgeX = forward ? width : 0.0;
      bezierStart1 = Offset(creaseX, 0);
      bezierControl1 = Offset(creaseX, 0);
      bezierVertex1 = Offset(edgeX, 0);
      bezierEnd1 = Offset(visibleTouchX, 0);
      bezierStart2 = Offset(creaseX, height);
      bezierControl2 = Offset(creaseX, height);
      bezierVertex2 = Offset(edgeX, height);
      bezierEnd2 = Offset(visibleTouchX, height);
      touchToCornerDistance = (adjustedTouch.dx - edgeX).abs();
      backTransform = _buildSideBackTransform(creaseX);
      isRightTopOrLeftBottom = forward;
      return;
    }
    isRightTopOrLeftBottom =
        (corner.dx == 0 && corner.dy == height) ||
        (corner.dx == width && corner.dy == 0);

    var touchX = _avoidEqual(touch.dx, corner.dx);
    var touchY = _avoidEqual(touch.dy, corner.dy);
    var points = _calculatePointsForTouch(Offset(touchX, touchY));

    if (touchX > 0 && touchX < width) {
      final start1X = points.start1.dx;
      if (start1X < 0 || start1X > width) {
        final normalizedStartX = start1X < 0 ? width - start1X : start1X;
        final f1 = (corner.dx - touchX).abs();
        if (f1 > 0.1 && normalizedStartX.abs() > 0.1) {
          final f2 = width * f1 / normalizedStartX;
          touchX = (corner.dx - f2).abs();
          final f3 =
              (corner.dx - touchX).abs() * (corner.dy - touchY).abs() / f1;
          touchY = (corner.dy - f3).abs();
          points = _calculatePointsForTouch(Offset(touchX, touchY));
        }
      }
    }

    adjustedTouch = Offset(touchX, touchY);
    bezierControl1 = points.control1;
    bezierControl2 = points.control2;
    bezierStart1 = points.start1;
    bezierStart2 = points.start2;
    bezierEnd1 = _cross(
      adjustedTouch,
      bezierControl1,
      bezierStart1,
      bezierStart2,
    );
    bezierEnd2 = _cross(
      adjustedTouch,
      bezierControl2,
      bezierStart1,
      bezierStart2,
    );
    bezierVertex1 = Offset(
      (bezierStart1.dx + 2 * bezierControl1.dx + bezierEnd1.dx) / 4,
      (2 * bezierControl1.dy + bezierStart1.dy + bezierEnd1.dy) / 4,
    );
    bezierVertex2 = Offset(
      (bezierStart2.dx + 2 * bezierControl2.dx + bezierEnd2.dx) / 4,
      (2 * bezierControl2.dy + bezierStart2.dy + bezierEnd2.dy) / 4,
    );
    touchToCornerDistance = (adjustedTouch - corner).distance;
    backTransform = _buildBackTransform();
  }

  _FoldPoints _calculatePointsForTouch(Offset point) {
    final middleX = (point.dx + corner.dx) / 2;
    final middleY = (point.dy + corner.dy) / 2;
    final cornerToMiddleX = _avoidZero(corner.dx - middleX);
    final cornerToMiddleY = corner.dy - middleY;
    final control1 = Offset(
      middleX - cornerToMiddleY * cornerToMiddleY / cornerToMiddleX,
      corner.dy,
    );
    final control2 = Offset(
      corner.dx,
      middleY -
          (corner.dx - middleX) *
              (corner.dx - middleX) /
              _avoidZero(corner.dy - middleY),
    );
    return _FoldPoints(
      control1: control1,
      control2: control2,
      start1: Offset(control1.dx - (corner.dx - control1.dx) / 2, corner.dy),
      start2: Offset(corner.dx, control2.dy - (corner.dy - control2.dy) / 2),
    );
  }

  Matrix4 _buildBackTransform() {
    final dis = math.sqrt(
      math.pow(corner.dx - bezierControl1.dx, 2) +
          math.pow(bezierControl2.dy - corner.dy, 2),
    );
    if (dis <= 0.1) return Matrix4.identity();
    final f8 = (corner.dx - bezierControl1.dx) / dis;
    final f9 = (bezierControl2.dy - corner.dy) / dis;
    final a = 1 - 2 * f9 * f9;
    final b = 2 * f8 * f9;
    final d = 1 - 2 * f8 * f8;
    return Matrix4.identity()
      ..setEntry(0, 0, a)
      ..setEntry(0, 1, b)
      ..setEntry(
        0,
        3,
        bezierControl1.dx - a * bezierControl1.dx - b * bezierControl1.dy,
      )
      ..setEntry(1, 0, b)
      ..setEntry(1, 1, d)
      ..setEntry(
        1,
        3,
        bezierControl1.dy - b * bezierControl1.dx - d * bezierControl1.dy,
      );
  }

  double get _sideCreaseX {
    final edgeX = forward ? size.width : 0.0;
    return ((adjustedTouch.dx + edgeX) / 2).clamp(0.0, size.width).toDouble();
  }

  double get _sideVisibleTouchX {
    return adjustedTouch.dx.clamp(0.0, size.width).toDouble();
  }

  Path get _sideFoldBackPath {
    final creaseX = _sideCreaseX;
    final touchX = _sideVisibleTouchX;
    final left = math.min(creaseX, touchX);
    final width = (creaseX - touchX).abs();
    return Path()..addRect(Rect.fromLTWH(left, 0, width, size.height));
  }

  Matrix4 _buildSideBackTransform(double x) {
    return Matrix4.identity()
      ..setEntry(0, 0, -1)
      ..setEntry(0, 3, 2 * x);
  }

  static Offset _cross(Offset p1, Offset p2, Offset p3, Offset p4) {
    final a1 = (p2.dy - p1.dy) / _avoidZero(p2.dx - p1.dx);
    final b1 = p1.dy - a1 * p1.dx;
    final a2 = (p4.dy - p3.dy) / _avoidZero(p4.dx - p3.dx);
    final b2 = p3.dy - a2 * p3.dx;
    final x = (b2 - b1) / _avoidZero(a1 - a2);
    final y = a1 * x + b1;
    if (x.isFinite && y.isFinite) return Offset(x, y);
    return p1;
  }

  static double _avoidEqual(double value, double target) {
    if ((value - target).abs() > 0.1) return value;
    return value < target ? target - 0.1 : target + 0.1;
  }

  static double _avoidZero(double value) {
    if (value.abs() > 0.1) return value;
    return value.isNegative ? -0.1 : 0.1;
  }
}

class _FoldPoints {
  const _FoldPoints({
    required this.control1,
    required this.control2,
    required this.start1,
    required this.start2,
  });

  final Offset control1;
  final Offset control2;
  final Offset start1;
  final Offset start2;
}

class _CurrentPageClipper extends CustomClipper<Path> {
  const _CurrentPageClipper(this.geometry);

  final _FoldGeometry geometry;

  @override
  Path getClip(Size size) => geometry.currentPagePath;

  @override
  bool shouldReclip(covariant _CurrentPageClipper oldClipper) =>
      oldClipper.geometry != geometry;
}

class _NextPageClipper extends CustomClipper<Path> {
  const _NextPageClipper(this.geometry);

  final _FoldGeometry geometry;

  @override
  Path getClip(Size size) => geometry.nextPagePath;

  @override
  bool shouldReclip(covariant _NextPageClipper oldClipper) =>
      oldClipper.geometry != geometry;
}

class _FoldBackClipper extends CustomClipper<Path> {
  const _FoldBackClipper(this.geometry);

  final _FoldGeometry geometry;

  @override
  Path getClip(Size size) => geometry.backVisiblePath;

  @override
  bool shouldReclip(covariant _FoldBackClipper oldClipper) =>
      oldClipper.geometry != geometry;
}

class _UnderPageShadowPainter extends CustomPainter {
  const _UnderPageShadowPainter({
    required this.geometry,
    required this.shadowColor,
  });

  final _FoldGeometry geometry;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (geometry.progress <= 0) return;
    if (geometry.fromSide) {
      _paintSideShadow(canvas, size);
      return;
    }
    canvas.save();
    canvas.clipPath(geometry.nextPagePath);
    canvas.translate(geometry.bezierStart1.dx, geometry.bezierStart1.dy);
    canvas.rotate(geometry.shadowAngle);
    canvas.translate(-geometry.bezierStart1.dx, -geometry.bezierStart1.dy);
    final extent = geometry.foldShadowExtent;
    final rect = geometry.isRightTopOrLeftBottom
        ? Rect.fromLTWH(
            geometry.bezierStart1.dx,
            geometry.bezierStart1.dy,
            extent,
            geometry.maxLength,
          )
        : Rect.fromLTWH(
            geometry.bezierStart1.dx - extent,
            geometry.bezierStart1.dy,
            extent,
            geometry.maxLength,
          );
    final paint = Paint()
      ..shader = LinearGradient(
        begin: geometry.isRightTopOrLeftBottom
            ? Alignment.centerLeft
            : Alignment.centerRight,
        end: geometry.isRightTopOrLeftBottom
            ? Alignment.centerRight
            : Alignment.centerLeft,
        colors: [
          _alpha(shadowColor, 0.34 * geometry.progress),
          _alpha(shadowColor, 0.10 * geometry.progress),
          _alpha(shadowColor, 0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  void _paintSideShadow(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipPath(geometry.nextPagePath);
    final width = math.max(28.0, math.min(76.0, size.width * 0.12));
    final creaseX = geometry.bezierStart1.dx;
    final rect = geometry.forward
        ? Rect.fromLTWH(creaseX, 0, width, size.height)
        : Rect.fromLTWH(math.max(0.0, creaseX - width), 0, width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: geometry.forward ? Alignment.centerLeft : Alignment.centerRight,
        end: geometry.forward ? Alignment.centerRight : Alignment.centerLeft,
        colors: [
          _alpha(shadowColor, 0.30 * geometry.progress),
          _alpha(shadowColor, 0.11 * geometry.progress),
          _alpha(shadowColor, 0),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _UnderPageShadowPainter oldDelegate) =>
      oldDelegate.geometry != geometry ||
      oldDelegate.shadowColor != shadowColor;
}

double _lerp(num a, num b, double t) => a + (b - a) * t;

Color _alpha(Color color, double alpha) =>
    color.withValues(alpha: alpha.clamp(0.0, 1.0));
