import 'package:eprs/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/domain/usecases/login_usecase.dart';

class LoginOverlay extends StatefulWidget {
  const LoginOverlay({super.key});

  @override
  State<LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends State<LoginOverlay> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _remember = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get controller from GetX (it should be registered via binding)
    final controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController(loginUseCase: Get.find<LoginUseCase>()));
    // MediaQuery size was previously used for logo sizing; layout is now
    // responsive via LayoutBuilder so `size` is unused.

    const greenColor = AppColors.primary;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: topPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top right language
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          'Eng',
                          style: GoogleFonts.poppins(
                            fontSize: isSmall ? 12 : 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmall ? 28 : 40),

                      // Logo
                      SizedBox(
                        height: logoHeight,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: isSmall ? 18 : 28),

                      // Title
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: isSmall ? 18 : 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),

                      SizedBox(height: largeSpacer),

                      // Inputs and actions — simplified and safer nesting
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 700),
                        child: Column(
                          children: [
                            // Phone field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white,
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: TextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 14 : 15,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: darkText,
                                  ),
                                  hintText: 'Email',
                                  hintStyle: GoogleFonts.poppins(
                                    color: hintText,
                                    fontSize: isSmall ? 13 : 15,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 16 : 20,
                                    horizontal: 20,
                                  ),
                                ),
                                onChanged: (v) =>
                                    controller.email.value = v,
                              ),
                            ),

                            SizedBox(height: betweenFields),

                            // Password
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.white,
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Obx(() => TextField(
                                controller: _passCtrl,
                                obscureText: controller.obscurePassword.value,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 14 : 15,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: darkText,
                                  ),
                                  hintText: 'Password',
                                  hintStyle: GoogleFonts.poppins(
                                    color: hintText,
                                    fontSize: isSmall ? 13 : 15,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isSmall ? 16 : 20,
                                    horizontal: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.obscurePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: hintText,
                                    ),
                                    onPressed: controller.togglePasswordVisibility,
                                  ),
                                ),
                                onChanged: (v) => controller.password.value = v,
                              )),
                            ),

                            SizedBox(height: betweenFields),

                            // Remember + Forgot
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _remember = !_remember),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: isSmall ? 18 : 20,
                                          height: isSmall ? 18 : 20,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: hintText,
                                              width: 1.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: _remember
                                                ? greenColor
                                                : Colors.transparent,
                                          ),
                                          child: _remember
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        SizedBox(width: isSmall ? 8 : 10),
                                        Flexible(
                                          child: Text(
                                            'Remember Me',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmall ? 13 : 14,
                                              color: darkText,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forget Password?',
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmall ? 13 : 14,
                                      color: blueColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isSmall ? 36 : 56),

                            // Buttons
                            Obx(() => SizedBox(
                              width: double.infinity,
                              height: isSmall ? 56 : 64,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.submitLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                                  disabledForegroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: controller.isLoading.value
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmall ? 16 : 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            )),

                            SizedBox(height: isSmall ? 14 : 20),

                            SizedBox(
                              width: double.infinity,
                              height: isSmall ? 52 : 56,
                              child: OutlinedButton(
                                onPressed: () => Get.toNamed(Routes.SIGNUP),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: greenColor,
                                    width: 1.6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Create Account',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmall ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                    color: greenColor,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: isSmall ? 14 : 22),

                            TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.HOME);
                              },
                              child: Text(
                                'Continue as Guest',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmall ? 14 : 15,
                                  color: hintText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
