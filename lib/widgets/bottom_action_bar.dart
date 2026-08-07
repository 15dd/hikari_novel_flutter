import 'package:flutter/material.dart';

class BottomActionBar extends StatefulWidget {
  final List<BottomActionItem> items;
  final double height;
  final bool edgeToEdge;

  const BottomActionBar({super.key, required this.items, required this.edgeToEdge, this.height = 72}) : assert(items.length >= 2 && items.length <= 3);

  @override
  State<StatefulWidget> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<BottomActionBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: EdgeInsets.only(bottom: widget.edgeToEdge ? MediaQuery.of(context).padding.bottom : 0),
      child: SizedBox(
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(widget.items.length, (index) {
            return Expanded(child: _ActionItem(item: widget.items[index]));
          }),
        ),
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.item});

  final BottomActionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconColor = colorScheme.primary;
    final labelColor = colorScheme.primary;

    return InkWell(
      onTap: item.onTap,
      splashColor: colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              child: Icon(item.icon, color: iconColor, size: 24),
            ),
            SizedBox(
              height: 16,
              child: Text(
                item.label,
                style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BottomActionItem({required this.icon, required this.label, required this.onTap});
}
