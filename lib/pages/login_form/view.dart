import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../router/route_path.dart';
import 'controller.dart';

class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final controller = Get.put(LoginFormController());
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top logo (horizontally centered)
                      Center(
                        child: Image.asset(
                          'assets/images/logo_transparent.png',
                          width: 140,
                          height: 140,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Wenku8 Reader',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _usernameCtrl,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        decoration: InputDecoration(
                          labelText: 'username'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'password'.tr,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _onLogin(),
                      ),
                      const SizedBox(height: 16),
                      Obx(
                        () => FilledButton.icon(
                          onPressed: controller.isSubmitting.value ? null : _onLogin,
                          icon: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.login),
                          label: Text(controller.isSubmitting.value ? 'logging_in'.tr : 'login'.tr),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'login_form_tip'.tr,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom-left: WebView login fallback button
            Positioned(
              left: 12,
              bottom: 12,
              child: TextButton.icon(
                onPressed: () => Get.toNamed(RoutePath.webLogin),
                icon: const Icon(Icons.public),
                label: Text('go_to_web_login'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLogin() {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      Get.dialog(
        AlertDialog(
          title: Text('error'.tr),
          content: Text('login_input_required'.tr),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('confirm'.tr)),
          ],
        ),
      );
      return;
    }
    controller.login(username: username, password: password);
  }
}
