import 'package:flutter/material.dart';
import 'package:hikari_novel_flutter/common/constants.dart';

class NormalTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget leading;
  final Widget? trailing;
  final void Function()? onTap;

  const NormalTile({required this.title, this.subtitle, required this.leading, this.trailing, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: kBaseTileTitleTextStyle),
      subtitle: subtitle == null ? null : Text(subtitle!, style: kBaseTileSubtitleTextStyle),
      leading: leading,
      trailing: Padding(
        padding: EdgeInsets.only(right: 4),
        child: Transform.scale(scale: 0.9, alignment: .centerRight, child: trailing),
      ),
    );
  }
}

class SwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget leading;
  final void Function()? onTap;
  final void Function(bool value) onChanged;
  final bool value;

  const SwitchTile({super.key, required this.title, this.subtitle, required this.leading, this.onTap, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(title, style: kBaseTileTitleTextStyle),
      subtitle: subtitle == null ? null : Text(subtitle!, style: kBaseTileSubtitleTextStyle),
      leading: leading,
      trailing: Transform.scale(
        scale: 0.9,
        alignment: .centerRight,
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}

class SliderTile extends StatefulWidget {
  final String title;
  final Widget leading;
  final num min;
  final num max;
  final int divisions;
  final int decimalPlaces;
  final num initValue;
  final void Function(double value)? onChangeEnd;

  const SliderTile({
    super.key,
    required this.title,
    required this.leading,
    required this.min,
    required this.max,
    required this.divisions,
    this.decimalPlaces = 2,
    required this.initValue,
    this.onChangeEnd,
  });

  @override
  State<StatefulWidget> createState() => _SliderTileState();
}

class _SliderTileState extends State<SliderTile> {
  late num interValue;

  @override
  void initState() {
    super.initState();
    interValue = widget.initValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.leading,
      title: Row(
        children: [
          Text(widget.title, style: kBaseTileTitleTextStyle),
          const Spacer(),
          Text(interValue.toStringAsFixed(widget.decimalPlaces), style: kBaseTileSubtitleTextStyle),
        ],
      ),
      subtitle: Slider(
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          divisions: widget.divisions,
          value: interValue.toDouble(),
          onChanged: (v) => setState(() => interValue = v),
          onChangeEnd: (v) => widget.onChangeEnd!.call(v)
      ),
    );
  }
}

Future<T?> showRadioListSheet<T>(
    BuildContext context, {
      required T value,
      required List<(T, String)> values,
      required String title,
      Widget Function(BuildContext, int)? subtitleBuilder,
      bool toggleable = false,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    enableDrag: true,
    builder: (_) {
      final titleMedium = TextTheme.of(context).titleMedium!;
      return SafeArea(
        child: _defaultBottomSheetColumn([
          _defaultBottomSheetTitlePadding(context, title),
          RadioGroup<T>(
            onChanged: (v) => Navigator.of(context).pop(v ?? value),
            groupValue: value,
            child: Column(
              mainAxisSize: .min,
              children: List.generate(values.length, (index) {
                final item = values[index];
                return RadioListTile<T>(
                  toggleable: toggleable,
                  value: item.$1,
                  title: Text(item.$2, style: titleMedium),
                  subtitle: subtitleBuilder?.call(context, index),
                );
              }),
            ),
          ),
        ]),
      );
    },
  );
}

Future<T?> showNormalListSheet<T>(
    BuildContext context, {
      required String title,
      required List<(T, String)> values,
      Widget Function(BuildContext, int)? subtitleBuilder,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    enableDrag: true,
    builder: (_) {
      final titleMedium = TextTheme.of(context).titleMedium!;
      return SafeArea(
        child: _defaultBottomSheetColumn([
          _defaultBottomSheetTitlePadding(context, title),
          Column(
            mainAxisSize: .min,
            children: List.generate(values.length, (index) {
              final item = values[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListTile(
                  title: Text(item.$2, style: titleMedium),
                  subtitle: subtitleBuilder?.call(context, index),
                  onTap: () => Navigator.of(context).pop(item.$1),
                ),
              );
            }),
          ),
        ]),
      );
    },
  );
}

Widget _defaultBottomSheetTitlePadding(BuildContext context, String title) {
  final titleLarge = TextTheme.of(context).titleLarge!;
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 0, 20),
    child: Text(title, style: titleLarge.copyWith(fontWeight: FontWeight.bold)),
  );
}

Widget _defaultBottomSheetColumn(List<Widget> children) =>
    Column(mainAxisSize: .min, crossAxisAlignment: .start, children: [...children, SizedBox(height: 10)]);
