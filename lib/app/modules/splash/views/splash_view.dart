// views/splash_view.dart
import 'package:eprs/app/modules/auth/views/signup_view.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/app/modules/home/controllers/home_controller.dart';
=======
import '../../login/views/login_view.dart';
>>>>>>> 70f8381050c9dbbb739d4088f4f215576f460a31

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoUp, _logoShrink, _formFade;

  final _phoneCtrl = TextEditingController();
  final _pwdCtrl   = TextEditingController();
  final _box       = GetStorage();
  final _isLoading = false.obs;
  final _phoneError = RxnString();

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));

    _logoUp     = Tween<double>(begin: 0, end: -220).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)));
    _logoShrink = Tween<double>(begin: 1.0, end: 0.48).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)));
    _formFade   = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.55, 0.85, curve: Curves.easeOut)));

    _ctrl.forward();

    _phoneCtrl.addListener(() {
      final raw = _phoneCtrl.text.trim();
      final isPlus = raw.startsWith('+251');
      final expected = isPlus ? 13 : 10;

      if (raw.isEmpty) {
        _phoneError.value = null;
      } else if ((isPlus && raw.length == 13 && raw[4] == '9') ||
                 (!isPlus && RegExp(r'^(09|07)\d{8}$').hasMatch(raw))) {
        _phoneError.value = null;
      } else {
        _phoneError.value = isPlus
            ? 'Use +2519xxxxxxxx (13 digits)'
            : 'Use 09/07xxxxxxxx (10 digits)';
      }
    });
=======
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Step 1: Fade in content
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => showContent = true);

    // Step 2: Hold for a moment
    await Future.delayed(const Duration(seconds: 2));

    // Step 3: Fade out + scale down
    setState(() => showContent = false);
    await Future.delayed(const Duration(milliseconds: 700));

    // Step 4: Navigate with custom transition
    if (mounted) {
      Navigator.of(context).pushReplacement(_createRoute());
    }
>>>>>>> 70f8381050c9dbbb739d4088f4f215576f460a31
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  void _signIn() async {
    final phoneRaw = _phoneCtrl.text.trim();
    final password = _pwdCtrl.text;

    if (phoneRaw.isEmpty || password.isEmpty) {
      _alert('Missing', 'Fill phone & password');
      return;
    }

    final phone = phoneRaw.startsWith('+251')
        ? phoneRaw.length == 13 ? '0${phoneRaw.substring(4)}' : null
        : phoneRaw;

    if (phone == null || !RegExp(r'^(09|07)\d{8}$').hasMatch(phone)) {
      _alert('Invalid Phone', 'Use 09xxxxxxxx or +2519xxxxxxxx');
      return;
    }

    if (password.length < 8) {
      _alert('Weak Password', '8+ characters required');
      return;
    }

    _isLoading(true);
    await Future.delayed(const Duration(seconds: 1));

    final savedPhone = _box.read('phone');
    if (savedPhone != phone) {
      _isLoading(false);
      _alert('Account Not Found', 'No account with this phone.\nTap "Create Account"');
      return;
    }

    if (_box.read('password') != password) {
      _isLoading(false);
      _alert('Wrong Password', 'Check your password');
      return;
    }

    _isLoading(false);
    Get.put(HomeController());
    Get.offAllNamed('/home', arguments: {'username': _box.read('username') ?? 'EPA User'});
  }

  void _alert(String title, String msg) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Text(msg, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
=======
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 700),
          opacity: showContent ? 1.0 : 0.0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: showContent ? 1.0 : 0.85,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    'assets/logo.png',
                    width: screenWidth * 0.9,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.error,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                SizedBox(height: screenHeight * 0.1),
              ],
            ),
>>>>>>> 70f8381050c9dbbb739d4088f4f215576f460a31
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final logoH = screenH * 0.68;

    return Scaffold(
      key: SplashView.navKey,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned(top: 20, right: 20, child: Text('Eng', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600))),

          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _logoUp.value),
              child: Transform.scale(
                scale: _logoShrink.value,
                child: Center(child: Image.asset('assets/logo.png', height: logoH, fit: BoxFit.contain)),
              ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: screenH * 0.38, left: 24, right: 24),
              child: FadeTransition(
                opacity: _formFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => _EPAField(
                      icon: Icons.phone_outlined,
                      hint: 'Phone number',
                      ctrl: _phoneCtrl,
                      type: TextInputType.phone,
                      error: _phoneError.value,
                    )),
                    const SizedBox(height: 14),
                    _EPAField(icon: Icons.lock_outline, hint: 'Password', ctrl: _pwdCtrl, obscure: true, showEye: true),
                    const SizedBox(height: 24),

                    // SIGN IN
                    Obx(() => _EPAButton(
                      text: _isLoading.value ? 'Signing In...' : 'Sign In',
                      onTap: _isLoading.value ? null : _signIn,
                    )),

                    const SizedBox(height: 12),

                    // FIXED: NOW WORKS 100%
                    _EPAButton(
                      text: 'Create Account',
                      primary: false,
                      onTap: () {
                        Get.to(() => const SiwgnupView());
                      },
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.offAllNamed('/home', arguments: {'username': 'Guest'}),
                      child: const Text('Continue as Guest', style: TextStyle(color: Color(0xFF6B7280))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// REUSABLE FIELD & BUTTON
class _EPAField extends StatefulWidget {
  final IconData icon;
  final String hint;
  final TextEditingController ctrl;
  final TextInputType? type;
  final bool obscure;
  final bool showEye;
  final String? error;
  const _EPAField({required this.icon, required this.hint, required this.ctrl, this.type, this.obscure = false, this.showEye = false, this.error});

  @override
  State<_EPAField> createState() => _EPAFieldState();
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
        prefixIcon: Icon(widget.icon, color: const Color(0xFF6B7280)),
        suffixIcon: widget.showEye
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF)),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2)),
        errorText: widget.error,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        counterText: widget.hint.contains('Phone')
            ? '${widget.ctrl.text.length}/${widget.ctrl.text.startsWith('+251') ? 13 : 10}'
            : '',
      ),
    );
  }
}

class _EPAButton extends StatelessWidget {
  final String text;
  final bool primary;
  final VoidCallback? onTap;
  const _EPAButton({required this.text, this.primary = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: primary
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: onTap,
              child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: Color(0xFFE5E7EB))),
              onPressed: onTap,
              child: Text(text),
            ),
    );
  }
}
=======
}

// 🔹 Transition Route Builder
Route _createRoute() {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 900),
    reverseTransitionDuration: const Duration(milliseconds: 700),
    pageBuilder: (context, animation, secondaryAnimation) => const LoginOverlay(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const beginOffset = Offset(0.0, 1.0); // Slide from bottom
      const endOffset = Offset.zero;
      final curve = Curves.easeInOutCubic;

      final tween = Tween(begin: beginOffset, end: endOffset)
          .chain(CurveTween(curve: curve));

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(tween),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
            child: child,
          ),
        ),
      );
    },
  );
}
>>>>>>> 70f8381050c9dbbb739d4088f4f215576f460a31
