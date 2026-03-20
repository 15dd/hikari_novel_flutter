import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/custom_exception.dart';
import 'package:wx_divider/wx_divider.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key, required this.msg, required this.action, this.buttonText = "retry", this.iconData = Icons.refresh});

  final String msg;
  final Function()? action;
  final String buttonText;
  final IconData iconData;

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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), child: _buildErrorInfo()),
          action == null ? Container() : FilledButton.icon(onPressed: action, icon: Icon(iconData), label: Text(buttonText.tr)),
        ],
      ),
    );
  }

  Widget _buildErrorInfo() {
    if (isSpecificMessage(msg)) {
      return _getCommonErrorInfoView(msg);
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
    return Center(child: Image.asset("assets/images/logo_transparent.png", width: 150, height: 150));
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
          const Icon(Icons.ads_click, size: 48),
          const SizedBox(height: 16),
          Text("please_select_type".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
          Text("empty_content".tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          onRefresh != null ? TextButton.icon(onPressed: onRefresh, icon: Icon(Icons.refresh), label: Text("refresh".tr)) : const SizedBox(),
        ],
      ),
    );
  }
}

Widget _getCommonErrorInfoView(String msg) {
  late String tip;
  if (msg.contains(cloudflareChallengeExceptionMessage)) {
    tip = "cloudflare_challenge_exception_tip".tr;
  } else if (msg.contains(cloudflare403ExceptionMessage)) {
    tip = "cloudflare_403_exception_tip".tr;
  }

  return SingleChildScrollView(
    child: Column(
      children: [
        Text(tip),
        const SizedBox(height: 6),
        WxDivider(pattern: WxDivider.dashed, color: Theme.of(Get.context!).colorScheme.onSurface,child: Text("Raw Message")),
        const SizedBox(height: 6),
        Text(msg),
      ],
    ),
  );
}

Future showErrorDialog(String msg, List<Widget> actions) {
  late Widget content;
  if (isSpecificMessage(msg)) {
    content = _getCommonErrorInfoView(msg);
  } else {
    content = SingleChildScrollView(child: Text(msg));
  }

  return Get.dialog(AlertDialog(title: Text("error".tr), content: content, actions: actions));
}

//参考https://pub.dev/packages/floating_snackbar
void showSnackBar({
  required String message, // The message to display in the SnackBar
  required BuildContext context, // The BuildContext to show the SnackBar within
  Duration? duration, // Optional: Duration for which the SnackBar is displayed
  TextStyle? textStyle, // Optional: Text style for the message text
}) {
  // Create a SnackBar widget with specified properties
  var snack = SnackBar(
    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10), // Set margin around the SnackBar
    duration: duration ?? const Duration(milliseconds: 4000), // Default duration if not provided
    content: Text(
      message, // Display the provided message text
      style: textStyle ?? TextStyle(), // Apply provided or default text style
    ),
  );

  // Hide any currently displayed SnackBar
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  // Show the created SnackBar
  ScaffoldMessenger.of(context).showSnackBar(snack);
}

bool isSpecificMessage(String msg) => msg.contains(cloudflareChallengeExceptionMessage) || msg.contains(cloudflare403ExceptionMessage);
