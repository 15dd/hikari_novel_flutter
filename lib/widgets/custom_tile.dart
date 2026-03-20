import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
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

class SliderTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final num min;
  final num max;
  final int divisions;
  final int decimalPlaces;
  final num value;
  final void Function(double value) onChanged;
  final void Function(double value)? onChangeEnd;

  const SliderTile({
    super.key,
    required this.title,
    required this.leading,
    required this.min,
    required this.max,
    required this.divisions,
    this.decimalPlaces = 2,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Row(
        children: [
          Text(title, style: kBaseTileTitleTextStyle),
          const Spacer(),
          Text(value.toStringAsFixed(decimalPlaces), style: kBaseTileSubtitleTextStyle),
        ],
      ),
      subtitle: Slider(min: min.toDouble(), max: max.toDouble(), divisions: divisions, value: value.toDouble(), onChanged: onChanged, onChangeEnd: onChangeEnd),
    );
  }
}

class RadioListDialog<T> extends StatelessWidget {
  final T? value;
  final String title;
  final List<(T, String)> values;
  final Widget Function(BuildContext, int)? subtitleBuilder;
  final bool toggleable;

  const RadioListDialog({super.key, required this.value, required this.values, required this.title, this.subtitleBuilder, this.toggleable = false});

  @override
  Widget build(BuildContext context) {
    final titleMedium = TextTheme.of(context).titleMedium!;
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      title: Text(title),
      constraints: subtitleBuilder != null ? const BoxConstraints(maxWidth: 320, minWidth: 320) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: Material(
        type: .transparency,
        child: SingleChildScrollView(
          child: RadioGroup<T>(
            onChanged: (v) => Navigator.of(context).pop(v ?? value),
            groupValue: value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
        ),
      ),
      actions: [TextButton(onPressed: Navigator.of(context).pop, child: Text("cancel".tr))],
    );
  }
}

class NormalListDialog<T> extends StatelessWidget {
  final String title;
  final List<(T, String)> values;
  final Widget Function(BuildContext, int)? subtitleBuilder;

  const NormalListDialog({super.key, required this.values, required this.title, this.subtitleBuilder});

  @override
  Widget build(BuildContext context) {
    final titleMedium = TextTheme.of(context).titleMedium!;
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      title: Text(title),
      constraints: subtitleBuilder != null ? const BoxConstraints(maxWidth: 320, minWidth: 320) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      content: Material(
        type: .transparency,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(values.length, (index) {
              final item = values[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: ListTile(
                  title: Text(item.$2, style: titleMedium),
                  subtitle: subtitleBuilder?.call(context, index),
                  onTap: () => Navigator.of(context).pop(item.$1),
                ),
              );
            }),
          ),
        ),
      ),
      actions: [TextButton(onPressed: Navigator.of(context).pop, child: Text("cancel".tr))],
    );
  }
}
