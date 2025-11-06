// lib/auth/views/signup_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/app/modules/home/controllers/home_controller.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    final box = GetStorage();

    final isLoading = false.obs;
    final phoneError = RxnString();
    final pwdError = RxnString();

    phoneCtrl.addListener(() {
      final raw = phoneCtrl.text.trim();
      if (raw.isEmpty) {
        phoneError.value = null;
      } else if (RegExp(r'^(09|07)\d{8}$').hasMatch(raw)) {
        phoneError.value = null;
      } else if (raw.startsWith('+251') && raw.length == 13 && raw[4] == '9') {
        phoneError.value = null;
      } else {
        phoneError.value = raw.startsWith('+251')
            ? 'Use +2519xxxxxxxx (13 digits)'
            : 'Use 09xxxxxxxx or 07xxxxxxxx (10 digits)';
      }
    });

    pwdCtrl.addListener(() {
      pwdError.value = pwdCtrl.text.length >= 8 ? null : 'Minimum 8 characters';
    });

    // FIXED: NO RETURN FROM SNACKBAR!
    void signup() async {
      final name = nameCtrl.text.trim();
      final phoneRaw = phoneCtrl.text.trim();
      final pwd = pwdCtrl.text;

      if (name.isEmpty) {
        Get.snackbar('⚠️ Name Required', 'Please enter your full name',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
      if (phoneError.value != null) {
        Get.snackbar('📱 Invalid Phone', phoneError.value!,
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }
      if (pwdError.value != null) {
        Get.snackbar('🔒 Weak Password', pwdError.value!,
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      final phone = phoneRaw.startsWith('+251')
          ? '0${phoneRaw.substring(4)}'
          : phoneRaw;

      isLoading(true);
      await Future.delayed(const Duration(milliseconds: 800));

      box.write('username', name);
      box.write('phone', phone);
      box.write('password', pwd);

      isLoading(false);

      Get.put(HomeController());
      Get.offAllNamed('/home', arguments: {'username': name});

      Get.snackbar('🎉 Welcome!', '$name, your EPA PASS is ready!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(child: Image.asset('assets/logo.png', height: 90)),
              const SizedBox(height: 40),
              const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Sign up to continue', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 48),

              _EPAField(icon: Icons.person_outline, hint: 'Full Name', ctrl: nameCtrl),
              const SizedBox(height: 20),

              Obx(() => _EPAField(
                icon: Icons.phone_outlined,
                hint: 'Phone number',
                ctrl: phoneCtrl,
                type: TextInputType.phone,
                error: phoneError.value,
                counter: '${phoneCtrl.text.length}/${phoneCtrl.text.startsWith('+251') ? 13 : 10}',
              )),
              const SizedBox(height: 20),

              Obx(() => _EPAField(
                icon: Icons.lock_outline,
                hint: 'Password',
                ctrl: pwdCtrl,
                obscure: true,
                showEye: true,
                error: pwdError.value,
              )),

              const SizedBox(height: 50),

              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading.value ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 18, 204, 61),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.deepPurple))
                      : const Text('Sign up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              )),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// SAME FIELD AS LOGIN
class _EPAField extends StatefulWidget {
  final IconData icon;
  final String hint;
  final TextEditingController ctrl;
  final TextInputType? type;
  final bool obscure;
  final bool showEye;
  final String? error;
  final String? counter;
  const _EPAField({
    required this.icon,
    required this.hint,
    required this.ctrl,
    this.type,
    this.obscure = false,
    this.showEye = false,
    this.error,
    this.counter,
  });

  @override State<_EPAField> createState() => _EPAFieldState();
}

class _EPAFieldState extends State<_EPAField> {
  late bool _obscure = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.ctrl,
      keyboardType: widget.type,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon, color: const Color(0xFF9CA3AF)),
        suffixIcon: widget.showEye
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF)),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.deepPurple, width: 2)),
        errorText: widget.error,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        counterText: widget.counter ?? '',
        counterStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}