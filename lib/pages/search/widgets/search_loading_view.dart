import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchLoadingView extends StatefulWidget {
  const SearchLoadingView({super.key, required this.isLoading, required this.onRetry});

  final bool isLoading;
  final VoidCallback onRetry;

  @override
  State<SearchLoadingView> createState() => _SearchLoadingViewState();
}

class _SearchLoadingViewState extends State<SearchLoadingView> {
  Timer? _timer;
  bool _hasShownTimeoutTip = false;

  @override
  void initState() {
    super.initState();
    _updateTimer();
  }

  @override
  void didUpdateWidget(covariant SearchLoadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      _updateTimer();
    }
  }

  void _updateTimer() {
    _timer?.cancel();
    _timer = null;

    if (!widget.isLoading) {
      _hasShownTimeoutTip = false;
      return;
    }

    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !widget.isLoading || _hasShownTimeoutTip) return;

      setState(() => _hasShownTimeoutTip = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !widget.isLoading,
      child: Center(
        child: _hasShownTimeoutTip
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("search_loading_too_long_tip".tr),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => _hasShownTimeoutTip = false);
                      _updateTimer();
                      widget.onRetry();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text("retry".tr),
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
