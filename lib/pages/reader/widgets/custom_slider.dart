import 'package:flutter/material.dart';

class CustomSlider extends StatelessWidget {
  const CustomSlider({
    required this.min,
    required this.max,
    required this.value,
    required this.divisions,
    required this.onChanged,
    required this.focusNode,
    this.reversed = false,
    super.key,
  });

  final double min;

  final double max;

  final double value;

  final int divisions;

  final void Function(double) onChanged;

  final FocusNode? focusNode;

  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = _SliderDefaultsM3(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: max - min > 0
          ? LayoutBuilder(
              builder: (context, constraints) => MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (details) {
                    var dx = details.localPosition.dx;
                    if (reversed) {
                      dx = constraints.maxWidth - dx;
                    }
                    var gap = constraints.maxWidth / divisions;
                    var gapValue = (max - min) / divisions;
                    onChanged.call((dx / gap).round() * gapValue + min);
                  },
                  onVerticalDragUpdate: (details) {
                    var dx = details.localPosition.dx;
                    if (dx > constraints.maxWidth || dx < 0) return;
                    if (reversed) {
                      dx = constraints.maxWidth - dx;
                    }
                    var gap = constraints.maxWidth / divisions;
                    var gapValue = (max - min) / divisions;
                    onChanged.call((dx / gap).round() * gapValue + min);
                  },
                  child: SizedBox(
                    height: 24,
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  height: 6,
                                  decoration: BoxDecoration(color: theme.inactiveTrackColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                ),
                              ),
                            ),
                            if (constraints.maxWidth / divisions > 10)
                              Positioned.fill(
                                child: Row(
                                  children: () {
                                    var res = <Widget>[];
                                    for (int i = 0; i < divisions - 1; i++) {
                                      res.add(const Spacer());
                                      res.add(
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                                        ),
                                      );
                                    }
                                    res.add(const Spacer());
                                    return res;
                                  }.call(),
                                ),
                              ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: reversed ? null : 0,
                              right: reversed ? 0 : null,
                              child: Center(
                                child: Container(
                                  width: constraints.maxWidth * ((value - min) / (max - min)),
                                  height: 8,
                                  decoration: BoxDecoration(color: theme.activeTrackColor, borderRadius: const BorderRadius.all(Radius.circular(10))),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: reversed ? null : constraints.maxWidth * ((value - min) / (max - min)) - 11,
                              right: !reversed ? null : constraints.maxWidth * ((value - min) / (max - min)) - 11,
                              child: Center(
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(color: theme.activeTrackColor, shape: BoxShape.circle),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _SliderDefaultsM3 extends SliderThemeData {
  _SliderDefaultsM3(this.context) : super(trackHeight: 4.0);

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;

  @override
  Color? get activeTrackColor => _colors.primary;

  @override
  Color? get inactiveTrackColor => _colors.surfaceContainerHighest;

  @override
  Color? get secondaryActiveTrackColor => _colors.primary;

  @override
  Color? get disabledActiveTrackColor => _colors.onSurface;

  @override
  Color? get disabledInactiveTrackColor => _colors.onSurface;

  @override
  Color? get disabledSecondaryActiveTrackColor => _colors.onSurface;

  @override
  Color? get activeTickMarkColor => _colors.onPrimary;

  @override
  Color? get inactiveTickMarkColor => _colors.onSurfaceVariant;

  @override
  Color? get disabledActiveTickMarkColor => _colors.onSurface;

  @override
  Color? get disabledInactiveTickMarkColor => _colors.onSurface;

  @override
  Color? get thumbColor => _colors.primary;

  @override
  Color? get disabledThumbColor => Color.alphaBlend(_colors.onSurface, _colors.surface);

  @override
  Color? get overlayColor => WidgetStateColor.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.dragged)) {
      return _colors.primary;
    }
    if (states.contains(WidgetState.hovered)) {
      return _colors.primary;
    }
    if (states.contains(WidgetState.focused)) {
      return _colors.primary;
    }

    return Colors.transparent;
  });

  @override
  TextStyle? get valueIndicatorTextStyle => Theme.of(context).textTheme.labelMedium!.copyWith(color: _colors.onPrimary);

  @override
  SliderComponentShape? get valueIndicatorShape => const DropSliderValueIndicatorShape();
}
