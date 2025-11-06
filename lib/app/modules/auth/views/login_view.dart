import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'signup_view.dart';
import '../../home/views/home_view.dart';
import 'package:eprs/app/modules/home/controllers/home_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController pwdCtrl = TextEditingController();
  bool loading = false;

  Future<void> _handleLogin() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    // For now, use stored username or phone as fallback
    final box = GetStorage();
    final savedUsername = box.read<String>('username');
    final username = (savedUsername?.isNotEmpty ?? false)
        ? savedUsername!
        : phoneCtrl.text.trim();
    setState(() => loading = false);
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    Get.offAll(() => HomeView(), arguments: {'username': username});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const FlutterLogo(size: 72),
              const SizedBox(height: 24),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to continue',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : _handleLogin,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Get.to(() => const SignupView()),
                  child: const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
