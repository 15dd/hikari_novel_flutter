import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'local_storage_service.dart';

class TtsService extends GetxService {
  static const MethodChannel _intentChannel = MethodChannel('hikari/system_intents');

  static TtsService get instance => Get.find<TtsService>();

  final FlutterTts _tts = FlutterTts();

  final enabled = false.obs;
  final engine = RxnString();
  final voice = Rxn<Map<String, String>>();
  final rate = 0.5.obs;
  final pitch = 1.0.obs;
  final volume = 1.0.obs;

  final engines = <String>[].obs;
  final voices = <Map<String, String>>[].obs;

  final isPlaying = false.obs;
  final isPaused = false.obs;
  final lastSpokenText = ''.obs;

  bool _pauseRequested = false;
  bool _stopRequested = false;

  final isSessionActive = false.obs;
  final sessionTitle = ''.obs;
  final sessionProgress = 0.0.obs;
  List<String> _chunks = const [];
  int _chunkIndex = 0;

  static const int _maxChunkLen = 140;

  static const String multiTtsEnginePackage = 'org.nobody.multitts';

  static const List<String> _preferredLocales = <String>['zh-CN', 'zh-TW', 'zh-HK', 'en-US'];

  Future<void> init() async {
    try { await _tts.awaitSpeakCompletion(true); } catch (_) {}

    _tts.setStartHandler(() {
      isPlaying.value = true;
      isPaused.value = false;
    });
    _tts.setCompletionHandler(() {
      _onChunkCompleted();
    });
    _tts.setCancelHandler(() {
      if (_pauseRequested) {
        _pauseRequested = false;
        isPlaying.value = false;
        isPaused.value = true;
        return;
      }
      _stopRequested = false;
      _endSession();
    });
    _tts.setPauseHandler(() {
      _pauseRequested = false;
      isPlaying.value = false;
      isPaused.value = true;
    });
    _tts.setContinueHandler(() {
      _pauseRequested = false;
      isPlaying.value = true;
      isPaused.value = false;
    });
    _tts.setErrorHandler((_) {
      if (_pauseRequested) {
        _pauseRequested = false;
        isPlaying.value = false;
        isPaused.value = true;
        return;
      }
      _stopRequested = false;
      _endSession();
    });

    enabled.value = LocalStorageService.instance.getReaderTtsEnabled();
    engine.value = LocalStorageService.instance.getReaderTtsEngine();
    voice.value = LocalStorageService.instance.getReaderTtsVoice();
    rate.value = LocalStorageService.instance.getReaderTtsRate();
    pitch.value = LocalStorageService.instance.getReaderTtsPitch();
    volume.value = LocalStorageService.instance.getReaderTtsVolume();

    await _tts.setSpeechRate(rate.value);
    await _tts.setPitch(pitch.value);
    await _tts.setVolume(volume.value);

    await _applyBestLanguage();

    await refreshEngines();

    final savedEngine = engine.value;
    final hasSaved = savedEngine != null && savedEngine.isNotEmpty && engines.contains(savedEngine);
    if (hasSaved) {
      await applyEngine(savedEngine);
    } else {
      await applyEngine(null);
    }

    await _applyBestLanguage();

    await refreshVoices();
    final savedVoice = voice.value;
    if (savedVoice != null && voices.any((v) => v['name'] == savedVoice['name'] && v['locale'] == savedVoice['locale'])) {
      await applyVoice(savedVoice);
    } else {
      voice.value = null;
      LocalStorageService.instance.setReaderTtsVoice(null);
    }
  }

  String displayEngineName(String enginePackage) {
    if (enginePackage == multiTtsEnginePackage) return 'MultiTTS';
    return '系统TTS';
  }

  Future<void> refreshEngines() async {
    if (!Platform.isAndroid) return;
    try {
      final result = await _tts.getEngines;
      final list = (result as List?)?.cast<String>() ?? <String>[];
      list.sort((a, b) {
        if (a == multiTtsEnginePackage && b != multiTtsEnginePackage) return -1;
        if (b == multiTtsEnginePackage && a != multiTtsEnginePackage) return 1;
        return a.compareTo(b);
      });
      engines.assignAll(list);
    } catch (e) {
      if (kDebugMode) {
        print('[TtsService] getEngines failed: $e');
      }
      engines.clear();
    }
  }

  Future<void> refreshVoices() async {
    try {
      final result = await _tts.getVoices;
      final list = <Map<String, String>>[];
      if (result is List) {
        for (final v in result) {
          if (v is Map) {
            final name = v['name']?.toString();
            final locale = v['locale']?.toString();
            if (name != null && locale != null) {
              list.add({'name': name, 'locale': locale});
            }
          }
        }
      }
      voices.assignAll(list);
    } catch (e) {
      if (kDebugMode) {
        print('[TtsService] getVoices failed: $e');
      }
      voices.clear();
    }
  }

  Future<void> setEnabled(bool v) async {
    enabled.value = v;
    LocalStorageService.instance.setReaderTtsEnabled(v);
    if (!v) await stop();
  }

  Future<void> applyEngine(String? e) async {
    engine.value = e;
    LocalStorageService.instance.setReaderTtsEngine(e);
    if (Platform.isAndroid && e != null && e.isNotEmpty) {
      try {
        await _tts.setEngine(e);
      } catch (err) {
        if (kDebugMode) {
          print('[TtsService] setEngine failed: $err');
        }
      }
    }
    await _applyBestLanguage();
  }

  Future<void> applyVoice(Map<String, String>? v) async {
    voice.value = v;
    LocalStorageService.instance.setReaderTtsVoice(v);
    if (v == null) return;
    try {
      await _tts.setVoice(v);
    } catch (err) {
      if (kDebugMode) {
        print('[TtsService] setVoice failed: $err');
      }
    }
  }

  Future<void> setRate(double v) async {
    rate.value = v;
    LocalStorageService.instance.setReaderTtsRate(v);
    await _tts.setSpeechRate(v);
  }

  Future<void> setPitch(double v) async {
    pitch.value = v;
    LocalStorageService.instance.setReaderTtsPitch(v);
    await _tts.setPitch(v);
  }

  Future<void> setVolume(double v) async {
    volume.value = v;
    LocalStorageService.instance.setReaderTtsVolume(v);
    await _tts.setVolume(v);
  }

  Future<void> refreshSettings({bool restartIfPlaying = true}) async {
    if (!enabled.value) return;

    if (restartIfPlaying && (isPlaying.value || isPaused.value || isSessionActive.value)) {
      try {
        await pauseSession();
      } catch (_) {}

      await _prepareForSpeak();

      try {
        await resumeSession();
      } catch (_) {
        if (lastSpokenText.value.trim().isNotEmpty) {
          await speak(lastSpokenText.value);
        }
      }
      return;
    }

    await _prepareForSpeak();
  }


  Future<void> openAndroidTtsSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _intentChannel.invokeMethod('openTtsSettings');
    } catch (e) {
      if (kDebugMode) {
        print('[TtsService] openTtsSettings failed: $e');
        Get.snackbar('提示', '无法打开系统TTS设置：$e');
      }
    }
  }

  Future<void> openAndroidApp(String packageName) async {
    if (!Platform.isAndroid) return;
    try {
      await _intentChannel.invokeMethod('openApp', {'package': packageName});
    } catch (e) {
      if (kDebugMode) {
        print('[TtsService] openApp failed: $e');
      }
    }
  }

  Future<void> openMultiTtsStore() async {
    final pkg = multiTtsEnginePackage;
    final market = Uri.parse('market://details?id=$pkg');
    final web = Uri.parse('https://play.google.com/store/apps/details?id=$pkg');
    if (await canLaunchUrl(market)) {
      await launchUrl(market, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(web)) {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  bool get isMultiTtsInstalled => engines.contains(multiTtsEnginePackage);

Future<void> speak(String text) async {
  if (!enabled.value) return;
  await _prepareForSpeak();
  isSessionActive.value = false;
  _chunks = const [];
  _chunkIndex = 0;
  sessionProgress.value = 0.0;
  lastSpokenText.value = text;
  final r = await _tts.speak(text);
  _handleSpeakResult(r);
}

Future<void> startChapter(String fullText, {String title = ''}) async {
  if (!enabled.value) return;
  await _prepareForSpeak();
  final cleaned = fullText.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (cleaned.isEmpty) return;

  sessionTitle.value = title;
  isSessionActive.value = true;
  isPaused.value = false;

  _chunks = _splitToChunks(cleaned);
  _chunkIndex = 0;
  sessionProgress.value = 0.0;

  lastSpokenText.value = cleaned;
  await _speakCurrentChunk();
}

Future<void> resumeSession() async {
  if (!enabled.value) return;
  await _prepareForSpeak();
  if (!isSessionActive.value) {
    if (lastSpokenText.value.trim().isNotEmpty) {
      await speak(lastSpokenText.value);
    }
    return;
  }
  if (isPaused.value) {
    final dynamic ttsDyn = _tts;
    try {
      isPaused.value = false;
      await ttsDyn.continueSpeaking();
      return;
    } catch (_) {
      try {
        isPaused.value = false;
        await ttsDyn.resume();
        return;
      } catch (_) {
      }
    }
  }
  isPaused.value = false;
  await _speakCurrentChunk();
}

Future<void> pauseSession() async {
  if (!enabled.value) return;
  _pauseRequested = true;
  _stopRequested = false;
  try {
    await _tts.pause();
  } catch (_) {
    try {
      await _tts.stop();
    } catch (_) {}
  }
  isPlaying.value = false;
  isPaused.value = true;
}

  Future<void> pause() async {
    if (isSessionActive.value) {
      await pauseSession();
      return;
    }
    try {
      _pauseRequested = true;
      _stopRequested = false;
      await _tts.pause();
    } catch (_) {}
  }

  Future<void> stop() async {
    _stopRequested = true;
    _pauseRequested = false;
    try {
      await _tts.stop();
    } catch (_) {}
    _endSession();
  }

  Future<void> _speakCurrentChunk() async {
    if (!isSessionActive.value) return;
    if (_chunkIndex < 0 || _chunkIndex >= _chunks.length) {
      _endSession();
      return;
    }
    final chunk = _chunks[_chunkIndex];
    try {
      final r = await _tts.speak(chunk);
      _handleSpeakResult(r);
    } catch (_) {
      _endSession();
      return;
    }
    sessionProgress.value = _chunks.isEmpty
        ? 0.0
        : (_chunkIndex / _chunks.length).clamp(0.0, 1.0);
  }

  Future<void> _prepareForSpeak() async {
    try {
      await _tts.setSpeechRate(rate.value);
      await _tts.setPitch(pitch.value);
      await _tts.setVolume(volume.value);
    } catch (_) {}
    await _applyBestLanguage();
  }

  Future<void> _applyBestLanguage() async {
    final fromVoice = voice.value?['locale'];
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();

    final candidates = <String>{
      if (fromVoice != null && fromVoice.trim().isNotEmpty) fromVoice,
      deviceLocale,
      ..._preferredLocales,
    }.toList();

    for (final loc in candidates) {
      if (await _trySetLanguage(loc)) {
        return;
      }
    }
  }

  Future<bool> _trySetLanguage(String locale) async {
    try {
      final available = await _tts.isLanguageAvailable(locale);
      if (available == null) {
        await _tts.setLanguage(locale);
        return true;
      }
      if (available is bool && !available) return false;
      await _tts.setLanguage(locale);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _handleSpeakResult(dynamic r) {
    if (r is int && r == 0) {
      if (_stopRequested || _pauseRequested) {
        if (kDebugMode) {
          print('[TtsService] speak() returned 0 but stop/pause was requested; suppressing error');
        }
        return;
      }
      if (kDebugMode) {
        print('[TtsService] speak() returned 0 (failed)');
      }
      isPlaying.value = false;
      isPaused.value = false;
      if (isSessionActive.value) {
        _endSession();
      }
      Get.snackbar('听书失败', '系统TTS没有开始播放。请在「系统TTS设置」里确认已安装引擎/语音，并尝试切换语言/引擎。');
    }
  }

  void _onChunkCompleted() {
    if (!isSessionActive.value) {
      isPlaying.value = false;
      isPaused.value = false;
      return;
    }
    if (isPaused.value) return;
    _chunkIndex += 1;
    if (_chunkIndex >= _chunks.length) {
      _endSession();
      return;
    }
    _speakCurrentChunk();
  }

  void _endSession() {
    isSessionActive.value = false;
    isPlaying.value = false;
    isPaused.value = false;
    _chunks = const [];
    _chunkIndex = 0;
    sessionProgress.value = 0.0;
  }

  List<String> _splitToChunks(String text) {
    final parts = text
        .split(RegExp(r'(?<=[。！？!?；;])'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final chunks = <String>[];
    final buf = StringBuffer();
    for (final p in parts.isEmpty ? [text] : parts) {
      if (buf.length + p.length <= _maxChunkLen) {
        buf.write(p);
      } else {
        if (buf.isNotEmpty) {
          chunks.add(buf.toString());
          buf.clear();
        }
        if (p.length <= _maxChunkLen) {
          buf.write(p);
        } else {
          for (var i = 0; i < p.length; i += _maxChunkLen) {
            chunks.add(p.substring(i, (i + _maxChunkLen).clamp(0, p.length)));
          }
        }
      }
    }
    if (buf.isNotEmpty) chunks.add(buf.toString());
    return chunks;
  }
}
