import 'dart:math' as math;
import 'dart:ui' as ui;

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
  const PaperCurlPager({
    super.key,
    this.controller,
    required this.pages,
    required this.initialIndex,
    this.interactivePageIndices = const <int>{},
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
  });

  final PaperCurlPagerController? controller;
  final List<Widget> pages;
  final int initialIndex;
  final Set<int> interactivePageIndices;
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

class _PaperCurlPagerState extends State<PaperCurlPager> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ValueNotifier<_PaperPoint> _paper = ValueNotifier<_PaperPoint>(_PaperPoint(const math.Point<double>(0, 0), const Size(1, 1)));

  Size _size = Size.zero;
  Offset _downPos = Offset.zero;
  math.Point<double> _currentA = const math.Point<double>(0, 0);
  bool _isForward = true;
  bool _isAnimating = false;
  bool _useClip = false;
  bool _fromTop = false;
  int _index = 0;

  bool get _dragStartsFromTopHalf => _downPos.dy <= (_size.height / 2);

  Offset _logicalOffset(Offset physical) {
    if (!widget.reverse || _size.width <= 0) return physical;
    return Offset((_size.width - physical.dx).clamp(0.0, _size.width), physical.dy);
  }

  int get _lastIndex => widget.pages.isEmpty ? 0 : widget.pages.length - 1;

  @override
  void initState() {
    super.initState();
    _index = _safeIndex(widget.initialIndex);
    _controller = AnimationController(vsync: this, duration: _effectiveDuration)
      ..addListener(_handleAnimationTick)
      ..addStatusListener(_handleAnimationStatus);
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
    final needResetIndex = widget.pages.length != oldWidget.pages.length || safeInitial != _index;
    if (!_isAnimating && needResetIndex) {
      _index = safeInitial;
      _resetToIdle();
    }
  }

  @override
  void dispose() {
    widget.controller?._unbind(_jumpToExternal);
    _controller.dispose();
    _paper.dispose();
    super.dispose();
  }

  Duration get _effectiveDuration => widget.animationEnabled ? widget.duration : const Duration(milliseconds: 1);

  int _safeIndex(int raw) {
    if (widget.pages.isEmpty) return 0;
    return raw.clamp(0, widget.pages.length - 1);
  }

  bool get _currentPageInteractive => widget.interactivePageIndices.contains(_index);

  void _jumpToExternal(int target) {
    final safeTarget = _safeIndex(target);
    if (_index == safeTarget && !_isAnimating) return;
    _controller.stop();
    _index = safeTarget;
    _resetToIdle();
    widget.onIndexChanged?.call(_index);
  }

  math.Point<double> _idlePoint() => math.Point(_size.width, _fromTop ? 0 : _size.height);

  _PaperPoint _makePaper(math.Point<double> point) {
    if (_size.width <= 0 || _size.height <= 0) {
      return _PaperPoint(point, _size);
    }
    if (_fromTop) {
      return _PaperPoint(math.Point(point.x, _size.height - point.y), _size);
    }
    return _PaperPoint(point, _size);
  }

  void _ensureSize(Size size) {
    if (_size == size) return;
    _size = size;
    if (_size.width <= 0 || _size.height <= 0) return;
    _useClip = false;
    _isAnimating = false;
    _isForward = true;
    _currentA = _idlePoint();
    _paper.value = _makePaper(_currentA);
  }

  void _resetToIdle() {
    if (_size.width <= 0 || _size.height <= 0) return;
    _useClip = false;
    _isAnimating = false;
    _isForward = true;
    _currentA = _idlePoint();
    _paper.value = _makePaper(_currentA);
    if (mounted) setState(() {});
  }

  void _handleAnimationTick() {
    if (_size.width <= 0 || _size.height <= 0) return;
    final targetY = _fromTop ? 0.0 : _size.height;
    if (_isForward) {
      _paper.value = _makePaper(math.Point(
        _currentA.x - (_currentA.x + _size.width) * _controller.value,
        _currentA.y + (targetY - _currentA.y) * _controller.value,
      ));
    } else {
      _paper.value = _makePaper(math.Point(
        _currentA.x + (_size.width - _currentA.x) * _controller.value,
        _currentA.y + (targetY - _currentA.y) * _controller.value,
      ));
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    final changed = _isForward;
    _isAnimating = false;
    _useClip = false;
    _paper.value = _makePaper(_idlePoint());
    if (mounted) {
      setState(() {});
    }
    if (changed) {
      _index = (_index + 1).clamp(0, _lastIndex);
    }
    widget.onIndexChanged?.call(_index);
  }

  void _animateNext({bool fromTop = false}) {
    if (_isAnimating || widget.pages.isEmpty || _index >= _lastIndex) {
      return;
    }
    final startY = fromTop ? 28.0.clamp(1.0, _size.height) : (_size.height - 28).clamp(1.0, _size.height);
    setState(() {
      _useClip = true;
      _isAnimating = true;
      _isForward = true;
      _fromTop = fromTop;
      _currentA = math.Point((_size.width - 28).clamp(1.0, _size.width), startY);
      _paper.value = _makePaper(_currentA);
    });
    _controller.forward(from: 0);
  }

  void _animatePrev({bool fromTop = false}) {
    if (_isAnimating || widget.pages.isEmpty || _index <= 0) {
      return;
    }
    final startY = fromTop ? 100.0.clamp(1.0, _size.height) : (_size.height - 100).clamp(1.0, _size.height);
    setState(() {
      _useClip = true;
      _isAnimating = true;
      _isForward = false;
      _fromTop = fromTop;
      _index = (_index - 1).clamp(0, _lastIndex);
      _currentA = math.Point(-200, startY);
      _paper.value = _makePaper(_currentA);
    });
    _controller.forward(from: 0);
  }

  void _handleTap(TapUpDetails details) {
    if (_size.width <= 0 || _size.height <= 0) return;
    if (_currentPageInteractive) {
      return;
    }
    final pos = _logicalOffset(details.localPosition);
    final x = pos.dx;
    final left = _size.width * widget.edgeTapWidthFactor;
    final right = _size.width * (1 - widget.edgeTapWidthFactor);
    final fromTop = pos.dy <= (_size.height / 2);
    if (x <= left) {
      if (_index <= 0) {
        widget.onReachStart?.call();
      } else {
        _animatePrev(fromTop: fromTop);
      }
      return;
    }
    if (x >= right) {
      if (_index >= _lastIndex) {
        widget.onReachEnd?.call();
      } else {
        _animateNext(fromTop: fromTop);
      }
      return;
    }
    widget.onCenterTap?.call();
  }

  void _handlePanDown(DragDownDetails details) {
    _downPos = _logicalOffset(details.localPosition);
    _fromTop = _downPos.dy <= (_size.height / 2);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isAnimating || widget.pages.isEmpty) return;
    if (_index >= _lastIndex) return;
    final move = _logicalOffset(details.localPosition);
    if (move.dx >= _size.width || move.dx < 0 || move.dy >= _size.height || move.dy < 0) {
      return;
    }
    if (_downPos.dx < _size.width / 2) {
      return;
    }
    if (!_useClip) {
      setState(() {
        _useClip = true;
      });
    }
    _fromTop = _dragStartsFromTopHalf;
    if (_downPos.dy > _size.height / 3 && _downPos.dy < _size.height * 2 / 3) {
      final lockedY = _fromTop ? 1.0 : (_size.height - 1);
      _currentA = math.Point(move.dx, lockedY);
      _paper.value = _makePaper(_currentA);
    } else {
      final clampedY = move.dy.clamp(0.0, _size.height);
      _currentA = math.Point(move.dx, clampedY);
      _paper.value = _makePaper(_currentA);
    }
    _isForward = ((_size.width - move.dx) / _size.width) > 0.33;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isAnimating || widget.pages.isEmpty) {
      return;
    }
    if (_downPos.dx < _size.width / 2) {
      if (_index <= 0) {
        widget.onReachStart?.call();
      } else {
        _animatePrev(fromTop: _dragStartsFromTopHalf);
      }
      return;
    }
    if (_index >= _lastIndex) {
      _resetToIdle();
      widget.onReachEnd?.call();
      return;
    }
    if (!_useClip) {
      return;
    }
    _isAnimating = true;
    _controller.forward(from: 0);
  }

  Widget _pageAt(int index) {
    if (widget.pages.isEmpty || index < 0 || index >= widget.pages.length) {
      return const SizedBox.shrink();
    }
    final background = widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
    Widget page = ColoredBox(color: background, child: SizedBox.expand(child: widget.pages[index]));
    if (widget.reverse) {
      page = Transform(alignment: Alignment.center, transform: Matrix4.diagonal3Values(-1, 1, 1), child: page);
    }
    return page;
  }

  Widget _buildInternalPager() {
    if (widget.pages.isEmpty) return const SizedBox.shrink();
    final underIndex = (_index + 1).clamp(0, _lastIndex);
    final background = widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final backside = widget.backsideColor ?? Color.lerp(background, Colors.black, Theme.of(context).brightness == Brightness.dark ? 0.24 : 0.14)!;
    return DecoratedBox(
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
              _pageAt(underIndex),
              ClipPath(
                clipper: _useClip ? _CurrentPaperClipper(_paper, _isForward, _fromTop) : null,
                child: _pageAt(_index),
              ),
              IgnorePointer(
                child: CustomPaint(
                  painter: _BookPainter(
                    _paper,
                    backside,
                    fromTop: _fromTop,
                    gutterColor: Theme.of(context).colorScheme.shadow.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.42 : 0.18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _ensureSize(size);
        Widget child = _buildInternalPager();
        if (widget.reverse) {
          child = Transform(alignment: Alignment.center, transform: Matrix4.diagonal3Values(-1, 1, 1), child: child);
        }
        return child;
      },
    );
  }
}

class _CurrentPaperClipper extends CustomClipper<Path> {
  const _CurrentPaperClipper(this.paper, this.isForward, this.fromTop) : super(reclip: paper);

  final ValueNotifier<_PaperPoint> paper;
  final bool isForward;
  final bool fromTop;

  Offset _offset(math.Point<double> point, Size size) => Offset(point.x, fromTop ? size.height - point.y : point.y);

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    if (paper.value.a == paper.value.f || paper.value.a.x <= -size.width) {
      return isForward ? Path() : full;
    }
    final c = _offset(paper.value.c, size);
    final e = _offset(paper.value.e, size);
    final b = _offset(paper.value.b, size);
    final a = _offset(paper.value.a, size);
    final k = _offset(paper.value.k, size);
    final h = _offset(paper.value.h, size);
    final j = _offset(paper.value.j, size);
    final f = _offset(paper.value.f, size);
    final folded = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(e.dx, e.dy, b.dx, b.dy)
      ..lineTo(a.dx, a.dy)
      ..lineTo(k.dx, k.dy)
      ..quadraticBezierTo(h.dx, h.dy, j.dx, j.dy)
      ..lineTo(f.dx, f.dy)
      ..close();
    return Path.combine(PathOperation.reverseDifference, folded, full);
  }

  @override
  bool shouldReclip(covariant _CurrentPaperClipper oldClipper) => paper != oldClipper.paper || isForward != oldClipper.isForward || fromTop != oldClipper.fromTop;
}

class _BookPainter extends CustomPainter {
  _BookPainter(this.paper, this.backsideColor, {required this.gutterColor, required this.fromTop}) : super(repaint: paper);

  final ValueNotifier<_PaperPoint> paper;
  final Color backsideColor;
  final Color gutterColor;
  final bool fromTop;

  Offset _offset(math.Point<double> point, Size size) => Offset(point.x, fromTop ? size.height - point.y : point.y);

  Path _pathFromPoints(Size size, List<math.Point<double>> points) {
    final out = Path();
    if (points.isEmpty) return out;
    final first = _offset(points.first, size);
    out.moveTo(first.dx, first.dy);
    for (final point in points.skip(1)) {
      final mapped = _offset(point, size);
      out.lineTo(mapped.dx, mapped.dy);
    }
    out.close();
    return out;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final p = paper.value;
    if (p.a == p.f || p.a.y == p.f.y) {
      final gutterRect = Rect.fromLTWH(size.width - 2, 0, 2, size.height);
      canvas.drawRect(gutterRect, Paint()..color = gutterColor.withOpacity(0.25));
      return;
    }
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final c = _offset(p.c, size);
    final e = _offset(p.e, size);
    final b = _offset(p.b, size);
    final a = _offset(p.a, size);
    final k = _offset(p.k, size);
    final h = _offset(p.h, size);
    final j = _offset(p.j, size);
    final f = _offset(p.f, size);
    final d = _offset(p.d, size);
    final i = _offset(p.i, size);
    final p1 = _offset(p.p1, size);
    final p2 = _offset(p.p2, size);
    final g = _offset(p.g, size);
    final ab = Path()
      ..moveTo(c.dx, c.dy)
      ..quadraticBezierTo(e.dx, e.dy, b.dx, b.dy)
      ..lineTo(a.dx, a.dy)
      ..lineTo(k.dx, k.dy)
      ..quadraticBezierTo(h.dx, h.dy, j.dx, j.dy)
      ..lineTo(f.dx, f.dy)
      ..close();
    final triangleB = Path()
      ..moveTo(d.dx, d.dy)
      ..lineTo(a.dx, a.dy)
      ..lineTo(i.dx, i.dy)
      ..close();
    final aShadowPaint = Paint()..style = PaintingStyle.fill;
    final xP1Delta = p.a.x - p.p1.x;
    final yP1Delta = p.a.y - p.p1.y;
    final aShadowLeftBezier = Path()
      ..moveTo(_offset(math.Point(p.c.x - xP1Delta, p.c.y), size).dx, _offset(math.Point(p.c.x - xP1Delta, p.c.y), size).dy)
      ..quadraticBezierTo(
        _offset(math.Point(p.e.x - xP1Delta, p.e.y - yP1Delta), size).dx,
        _offset(math.Point(p.e.x - xP1Delta, p.e.y - yP1Delta), size).dy,
        _offset(math.Point(p.b.x - xP1Delta, p.b.y - yP1Delta), size).dx,
        _offset(math.Point(p.b.x - xP1Delta, p.b.y - yP1Delta), size).dy,
      )
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(k.dx, k.dy)
      ..lineTo(f.dx, f.dy)
      ..close();
    final xP2Delta = p.a.x - p.p2.x;
    final yP2Delta = p.a.y - p.p2.y;
    final aShadowRight = Path()
      ..moveTo(_offset(math.Point(p.j.x, p.j.y - yP2Delta), size).dx, _offset(math.Point(p.j.x, p.j.y - yP2Delta), size).dy)
      ..quadraticBezierTo(
        _offset(math.Point(p.i.x - xP2Delta, p.i.y - yP2Delta), size).dx,
        _offset(math.Point(p.i.x - xP2Delta, p.i.y - yP2Delta), size).dy,
        _offset(math.Point(p.k.x - xP2Delta, p.k.y - yP2Delta), size).dx,
        _offset(math.Point(p.k.x - xP2Delta, p.k.y - yP2Delta), size).dy,
      )
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(f.dx, f.dy)
      ..close();
    final combineShadowLeft = Path.combine(PathOperation.reverseDifference, ab, aShadowLeftBezier);
    final combineShadowRight = Path.combine(PathOperation.reverseDifference, ab, aShadowRight);
    canvas.drawPath(combineShadowLeft, aShadowPaint..shader = ui.Gradient.linear(a, p1, [Colors.black26, Colors.transparent]));
    canvas.drawPath(combineShadowRight, aShadowPaint..shader = ui.Gradient.linear(a, p2, [Colors.black26, Colors.transparent]));
    final crossPoint = _calculateIntersectionOfTwoLines(
      math.Point(p.b.x - xP1Delta, p.b.y - yP1Delta),
      p.p1,
      p.p2,
      math.Point(p.k.x - xP2Delta, p.k.y - yP2Delta),
    );
    final crossOffset = _offset(crossPoint, size);
    final crossShadowLeft = Path()..moveTo(a.dx, a.dy)..lineTo(crossOffset.dx, crossOffset.dy)..lineTo(p1.dx, p1.dy)..close();
    canvas.drawPath(crossShadowLeft, aShadowPaint..shader = ui.Gradient.linear(a, p1, [Colors.black26, Colors.transparent]));
    final crossShadowRight = Path()..moveTo(a.dx, a.dy)..lineTo(crossOffset.dx, crossOffset.dy)..lineTo(p2.dx, p2.dy)..close();
    canvas.drawPath(crossShadowRight, aShadowPaint..shader = ui.Gradient.linear(a, p2, [Colors.black26, Colors.transparent]));
    final backsidePaint = Paint()..style = PaintingStyle.fill;
    final regionB = Path.combine(PathOperation.intersect, ab, triangleB);
    canvas.drawPath(regionB, backsidePaint..color = backsideColor);
    final bShadow = _pathFromPoints(size, [p.c, p.j, p.h, p.e]);
    final combineToBC = Path.combine(PathOperation.intersect, bShadow, ab);
    final combineToC = Path.combine(PathOperation.difference, combineToBC, regionB);
    final uRaw = _calculateIntersectionOfTwoLines(p.a, p.f, p.d, p.i);
    final u = _offset(uRaw, size);
    canvas.drawPath(combineToC, backsidePaint..shader = ui.Gradient.linear(u, g, [Colors.black38, Colors.transparent]));
    final fullShadow = Paint()..shader = ui.Gradient.linear(Offset(size.width - 12, 0), Offset(size.width, 0), [gutterColor.withOpacity(0.06), gutterColor.withOpacity(0.22)]);
    canvas.drawPath(Path.combine(PathOperation.intersect, full, Path()..addRect(Rect.fromLTWH(size.width - 18, 0, 18, size.height))), fullShadow);
  }

  @override
  bool shouldRepaint(covariant _BookPainter oldDelegate) => oldDelegate.paper != paper || oldDelegate.backsideColor != backsideColor || oldDelegate.gutterColor != gutterColor || oldDelegate.fromTop != fromTop;
}

class _PaperPoint {
  _PaperPoint(this.a, this.size, {this.elevationC = 10}) {
    f = math.Point(size.width, size.height);
    if ((a.x - f.x).abs() < 0.001 && (a.y - f.y).abs() < 0.001) {
      g = f;
      b = f;
      c = f;
      d = f;
      e = f;
      h = f;
      i = f;
      j = f;
      k = f;
      p1 = f;
      p2 = f;
      return;
    }
    g = math.Point((a.x + f.x) / 2, (a.y + f.y) / 2);
    e = math.Point(g.x - (math.pow(f.y - g.y, 2) / (f.x - g.x)), f.y);
    var cx = e.x - (f.x - e.x) / 2;
    if (a.x > 0 && cx <= 0) {
      final fc = f.x - cx;
      final fa = f.x - a.x;
      final bb1 = size.width * fa / fc;
      final fd1 = f.y - a.y;
      final fd = bb1 * fd1 / fa;
      a = math.Point(f.x - bb1, f.y - fd);
      g = math.Point((a.x + f.x) / 2, (a.y + f.y) / 2);
      e = math.Point(g.x - (math.pow((f - g).y, 2) / (f - g).x), f.y);
      cx = 0;
    }
    c = math.Point(cx, f.y);
    h = math.Point(f.x, g.y - (math.pow((f - g).x, 2) / (f.y - g.y)));
    j = math.Point(f.x, h.y - (f.y - h.y) / 2);
    final ah = _calculateLineEquation(a, h);
    final ae = _calculateLineEquation(a, e);
    b = _calculateIntersectionOfTwoLines(c, j, a, e);
    k = _calculateIntersectionOfTwoLines(c, j, a, h);
    final tp = math.Point((c.x + b.x) / 2, (c.y + b.y) / 2);
    final to = math.Point((j.x + k.x) / 2, (j.y + k.y) / 2);
    d = math.Point((tp.x + e.x) / 2, (tp.y + e.y) / 2);
    i = math.Point((to.x + h.x) / 2, (to.y + h.y) / 2);
    p1 = _projectPointToLine(ah, elevationC);
    p2 = _projectPointToLine(ae, elevationC);
  }

  math.Point<double> a;
  final double elevationC;
  late math.Point<double> f;
  late math.Point<double> p1;
  late math.Point<double> p2;
  late math.Point<double> b, c, d, e;
  late math.Point<double> h, i, j, k;
  late math.Point<double> g;
  final Size size;
}

class _Line {
  const _Line(this.a, this.b, this.slope, this.intercept);

  final math.Point<double> a;
  final math.Point<double> b;
  final double slope;
  final double intercept;
}

_Line _calculateLineEquation(math.Point<double> p1, math.Point<double> p2) {
  double slope = 0;
  double intercept = 0;
  if (p1.x == p2.x) {
    if (p1.y == p2.y) {
      slope = double.nan;
    } else {
      slope = p1.y > p2.y ? double.infinity : double.negativeInfinity;
    }
  } else {
    slope = (p1.y - p2.y) / (p1.x - p2.x);
  }
  if (slope.isNaN || slope.isInfinite) {
    intercept = double.nan;
  } else {
    intercept = p1.y - slope * p1.x;
  }
  return _Line(p1, p2, slope, intercept);
}

math.Point<double> _calculateIntersectionOfTwoLines(math.Point<double> a, math.Point<double> b, math.Point<double> m, math.Point<double> n) {
  final line1 = _calculateLineEquation(a, b);
  final line2 = _calculateLineEquation(m, n);
  final x = (line2.intercept - line1.intercept) / (line1.slope - line2.slope);
  final y = x * line1.slope + line1.intercept;
  return math.Point(x, y);
}

math.Point<double> _projectPointToLine(_Line line, double distance) {
  final slope = line.slope;
  late final double x;
  late final double y;
  if (slope > 0 || line.a.y >= line.b.y) {
    x = line.a.x - math.sqrt(distance * distance / (1 + (slope * slope)));
    y = line.a.y - math.sqrt(distance * distance / (1 + (slope * slope))) * slope;
  } else {
    x = line.a.x + math.sqrt(distance * distance / (1 + (slope * slope)));
    y = line.a.y + math.sqrt(distance * distance / (1 + (slope * slope))) * slope;
  }
  return math.Point(x, y);
}
