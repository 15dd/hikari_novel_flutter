import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../service/tts_service.dart';
import '../controller.dart';

class TtsFloatingController extends StatefulWidget {
  const TtsFloatingController({super.key});

  @override
  State<TtsFloatingController> createState() => _TtsFloatingControllerState();
}

class _TtsFloatingControllerState extends State<TtsFloatingController> {
  Offset offset = const Offset(16, 180);

  @override
  Widget build(BuildContext context) {
    final tts = TtsService.instance;
    final reader = Get.find<ReaderController>();

    return Obx(() {
      final visible = tts.enabled.value && (tts.isPlaying.value || tts.isPaused.value);
      if (!visible) return const SizedBox.shrink();

      final size = MediaQuery.of(context).size;
      final safeTop = MediaQuery.of(context).padding.top + 8;
      final safeBottom = MediaQuery.of(context).padding.bottom + 8;
      final clamped = Offset(offset.dx.clamp(8, size.width - 8 - 240), offset.dy.clamp(safeTop, size.height - safeBottom - 56));
      offset = clamped;

      return Positioned(
        left: offset.dx,
        top: offset.dy,
        child: Draggable(
          feedback: _buildCard(context, tts, reader, dragging: true),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            setState(() => offset = details.offset);
          },
          child: _buildCard(context, tts, reader),
        ),
      );
    });
  }

  Widget _buildCard(BuildContext context, TtsService tts, ReaderController reader, {bool dragging = false}) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface;
    final fg = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      elevation: dragging ? 8 : 4,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 240,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.record_voice_over_outlined, color: fg.withOpacity(0.75), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "listen_to_books".tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: kBaseTileSubtitleTextStyle.copyWith(color: fg),
              ),
            ),
            IconButton(
              tooltip: tts.isPlaying.value ? "pause".tr : "play".tr,
              iconSize: 22,
              onPressed: () async {
                if (tts.isPlaying.value) {
                  await tts.pauseSession();
                } else if (tts.isPaused.value && tts.isSessionActive.value) {
                  await tts.resumeSession();
                } else {
                  final text = reader.text.value;
                  final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
                  if (cleaned.isNotEmpty) {
                    await tts.startChapter(cleaned);
                  }
                }
              },
              icon: Icon(tts.isPlaying.value ? Icons.pause_circle_outline : Icons.play_circle_outline),
            ),
            IconButton(tooltip: "stop".tr, iconSize: 22, onPressed: () => tts.stop(), icon: const Icon(Icons.stop_circle_outlined)),
            IconButton(tooltip: "exit".tr, iconSize: 22, onPressed: () => tts.stop(), icon: const Icon(Icons.close)),
          ],
        ),
      ),
    );
  }
}
