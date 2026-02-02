import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ErrorMessage extends StatelessWidget {
  // Keep `onRetry` for backward compatibility with existing call sites.
  // The UI intentionally does NOT render a retry button.
  const ErrorMessage({super.key, required this.msg, this.onRetry});

  final String msg;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "error".tr,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: _buildErrorInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorInfo() {
    if (msg.contains("Cloudflare Challenge Detected")) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Text("cloudflare_challenge_exception_tip".tr),
            const SizedBox(width: 50, child: Divider()),
            Text(msg),
          ],
        ),
      );
    } else {
      return SingleChildScrollView(child: Text(msg));
    }
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/images/logo_transparent.png",
        width: 150,
        height: 150,
      ),
    );
  }
}

class PleaseSelectPage extends StatelessWidget {
  const PleaseSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Symbols.web_traffic, size: 48),
          const SizedBox(height: 16),
          Text(
            "please_select_type".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class EmptyPage extends StatelessWidget {
  final Function()? onRefresh;

  const EmptyPage({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox, size: 48),
          const SizedBox(height: 16),
          Text(
            "empty_content".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (onRefresh != null)
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text("refresh".tr),
            ),
        ],
      ),
    );
  }
}

Future showErrorDialog(String msg, List<Widget> actions) {
  late Widget content;
  if (msg.contains("Cloudflare Challenge Detected")) {
    content = SingleChildScrollView(
      child: Column(
        children: [
          Text("cloudflare_challenge_exception_tip".tr),
          const SizedBox(width: 50, child: Divider()),
          Text(msg),
        ],
      ),
    );
  } else {
    content = SingleChildScrollView(child: Text(msg));
  }

  return Get.dialog(
    AlertDialog(title: Text("error".tr), content: content, actions: actions),
  );
}