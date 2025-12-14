import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_calling_system/app_constants/utils/colors.dart';
import 'package:video_calling_system/app_constants/utils/global_textstyle.dart';
import 'package:video_calling_system/app_constants/widgets/auth_text_field.dart';
import 'package:video_calling_system/feature/auth/controllers/auth_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final AuthController _auth = Get.find<AuthController>();
  final SignupFormController form = Get.put(SignupFormController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: const Color(0xFFE8FEFC),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.vertical,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Create account',
                    textAlign: TextAlign.center,
                    style: GlobalTextStyle.heading(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign up to start messaging and calling',
                    textAlign: TextAlign.center,
                    style: GlobalTextStyle.body(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 420,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AuthTextField(
                              controller: form.emailController,
                              label: 'Email',
                              hint: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : 'Enter a valid email',
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: form.nameController,
                              label: 'Full name',
                              hint: 'Jane Doe',
                              validator: (v) => v != null && v.trim().isNotEmpty
                                  ? null
                                  : 'Name is required',
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: form.passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              obscureText: true,
                              validator: (v) => v != null && v.length >= 6
                                  ? null
                                  : 'Min 6 characters',
                            ),
                            const SizedBox(height: 12),
                            AuthTextField(
                              controller: form.confirmController,
                              label: 'Confirm Password',
                              hint: '••••••••',
                              obscureText: true,
                              validator: (v) => v == form.passwordController.text
                                  ? null
                                  : 'Passwords do not match',
                            ),
                            const SizedBox(height: 18),
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _auth.isLoading.value
                                      ? null
                                      : () async {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            await _auth.signUp(
                                              form.emailController.text.trim(),
                                              form.passwordController.text,
                                              displayName:
                                                  form.nameController.text,
                                            );
                                            Get.until((route) => route.isFirst);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _auth.isLoading.value
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text('Sign Up'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: GlobalTextStyle.body(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Sign in',
                          style: GlobalTextStyle.body(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
