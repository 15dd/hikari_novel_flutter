import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/custom_exception.dart';
import 'package:hikari_novel_flutter/models/page_state.dart';
import 'package:hikari_novel_flutter/widgets/state_page.dart';

import '../../router/route_path.dart';
import 'controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.pageState.value == PageState.error) {
        return Scaffold(
          body: ErrorMessage(
            msg: controller.errorMsg.value,
            action: () => Get.offAllNamed(RoutePath.welcome),
            buttonText: "re_login",
          ),
        );
      }
      final image = controller.captcha.value;
      return Scaffold(
        appBar: AppBar(title: Text("login".tr)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              TextField(
                controller: controller.usernameController,
                decoration: InputDecoration(labelText: "username".tr),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "password".tr),
              ),
              if (controller.needCheckcode.value) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: controller.checkcodeController,
                  decoration: InputDecoration(labelText: "checkcode".tr),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: controller.refreshCaptcha,
                    child: image == null
                        ? const SizedBox(
                            width: 120,
                            height: 40,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Image.memory(image, height: 40),
                  ),
                ),
              ],
              if (controller.errorMsg.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _loginMessage(controller.errorMsg.value),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: controller.submitting.value ? null : controller.submit,
                child: Text("login".tr),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _loginMessage(String msg) {
    if (msg.contains(cloudflare403ExceptionMessage)) {
      return "cloudflare_403_exception_tip".tr;
    }
    if (msg.contains(cloudflareChallengeExceptionMessage)) {
      return "cloudflare_challenge_exception_tip".tr;
    }
    if (msg.contains(cloudflare429ExceptionMessage)) {
      return "cloudflare_429_exception_tip".tr;
    }
    return msg;
  }
}
