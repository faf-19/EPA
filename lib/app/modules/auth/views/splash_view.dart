import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _moveUpAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _moveUpAnim = Tween<double>(
      begin: 0,
      end: -80,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation after brief delay, then navigate
    Future.delayed(const Duration(milliseconds: 500), () async {
      await _controller.forward();
      // Short pause, then go to login
      Future.delayed(const Duration(milliseconds: 500), () async {
        final box = GetStorage();
        final savedUsername = box.read<String>('username');
        if (savedUsername != null && savedUsername.isNotEmpty) {
          Get.offAllNamed(
            '/login',
          ); // go to login so user can proceed; you may auto-login later
        } else {
          Get.offAll(() => const LoginView());
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top-right language label
          Positioned(
            top: 16,
            right: 16,
            child: Text(
              'Eng',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Center animated logo
          Center(
            child: AnimatedBuilder(
              animation: _moveUpAnim,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _moveUpAnim.value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Replace with your asset logo to match the mock
                    // Fallback to FlutterLogo if the asset is missing.
                    Image.asset(
                      'assets/images/epa_logo.png',
                      height: 110,
                      errorBuilder: (_, __, ___) => const FlutterLogo(size: 96),
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
