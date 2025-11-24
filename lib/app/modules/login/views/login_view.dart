import 'package:eprs/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';

class LoginOverlay extends StatefulWidget {
  const LoginOverlay({super.key});

  @override
  State<LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends State<LoginOverlay> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _remember = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    // MediaQuery size was previously used for logo sizing; layout is now
    // responsive via LayoutBuilder so `size` is unused.

    const greenColor = Color(0xFF00A650);
    const blueColor = Color(0xFF0047BA);
    const darkText = Color(0xFF0F3B52);
    const hintText = Color(0xFF9BA5B1);
    const borderColor = Color(0xFFE0E6ED);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle radial gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFFF8FAFB),
                  Color(0xFFF5F7FA),
                  Color(0xFFF8FAFB),
                ],
                center: Alignment.topCenter,
                radius: 1.2,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              // Adapt sizes based on available height — avoid scrolling by
              // reducing spacing and image sizes on small screens.
              final height = constraints.maxHeight;
              final isSmall = height < 700;
              // increase logo size to better match the design
              final logoHeight = isSmall ? 160.0 : 240.0;
              // more top padding on larger screens, a bit for small screens too
              final topPadding = isSmall ? 20.0 : 40.0;
              // slightly larger gaps between fields to match mock spacing
              final betweenFields = isSmall ? 16.0 : 22.0;
              // space between title and the inputs — larger to visually separate sections
              final largeSpacer = isSmall ? 36.0 : 56.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: topPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top right language
                    Align(
                      alignment: Alignment.topRight,
                      child: Text('Eng', style: GoogleFonts.poppins(fontSize: isSmall ? 12 : 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
                    ),

                    SizedBox(height: isSmall ? 28 : 64),

                    // Logo
                    SizedBox(
                      height: logoHeight,
                      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                    ),

                    SizedBox(height: isSmall ? 18 : 28),

                    // Title
                    Text('Welcome Back!', style: GoogleFonts.poppins(fontSize: isSmall ? 18 : 24, fontWeight: FontWeight.w600, color: darkText)),

                    SizedBox(height: largeSpacer),

                    // Inputs and actions — simplified and safer nesting
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 700),
                      child: Column(
                        children: [
                          // Phone field
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white, border: Border.all(color: borderColor, width: 1.2)),
                            child: TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.poppins(fontSize: isSmall ? 14 : 15),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.phone_outlined, color: darkText),
                                hintText: 'Phone number',
                                hintStyle: GoogleFonts.poppins(color: hintText, fontSize: isSmall ? 13 : 15),
                                contentPadding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 20, horizontal: 20),
                              ),
                              onChanged: (v) => controller.phoneNumber.value = v,
                            ),
                          ),

                          SizedBox(height: betweenFields),

                          // Password
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: Colors.white, border: Border.all(color: borderColor, width: 1.2)),
                            child: TextField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              style: GoogleFonts.poppins(fontSize: isSmall ? 14 : 15),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: const Icon(Icons.lock_outline, color: darkText),
                                hintText: 'Password',
                                hintStyle: GoogleFonts.poppins(color: hintText, fontSize: isSmall ? 13 : 15),
                                contentPadding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 20, horizontal: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: hintText),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: betweenFields),

                          // Remember + Forgot
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _remember = !_remember),
                                child: Row(
                                  children: [
                                    Container(
                                      width: isSmall ? 18 : 20,
                                      height: isSmall ? 18 : 20,
                                      decoration: BoxDecoration(border: Border.all(color: hintText, width: 1.2), borderRadius: BorderRadius.circular(4), color: _remember ? greenColor : Colors.transparent),
                                      child: _remember ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                    ),
                                    SizedBox(width: isSmall ? 8 : 10),
                                    Text('Remember Me', style: GoogleFonts.poppins(fontSize: isSmall ? 13 : 14, color: darkText, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: Text('Forget Password?', style: GoogleFonts.poppins(fontSize: isSmall ? 13 : 14, color: blueColor, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),

                          SizedBox(height: isSmall ? 36 : 56),

                          // Buttons
                          SizedBox(
                            width: double.infinity,
                            height: isSmall ? 56 : 64,
                            child: ElevatedButton(
                              onPressed: () => {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: Text('Sign In', style: GoogleFonts.poppins(fontSize: isSmall ? 16 : 18, fontWeight: FontWeight.w600)),
                            ),
                          ),

                          SizedBox(height: isSmall ? 14 : 20),

                          SizedBox(
                            width: double.infinity,
                            height: isSmall ? 52 : 56,
                            child: OutlinedButton(
                              onPressed: () => Get.toNamed(Routes.SIGNUP),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: greenColor, width: 1.6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Create Account', style: GoogleFonts.poppins(fontSize: isSmall ? 16 : 18, fontWeight: FontWeight.w600, color: greenColor)),
                            ),
                          ),

                          SizedBox(height: isSmall ? 14 : 22),

                          TextButton(onPressed: () {}, child: Text('Continue as Guest', style: GoogleFonts.poppins(fontSize: isSmall ? 14 : 15, color: hintText, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
