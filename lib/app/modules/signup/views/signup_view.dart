import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/signup_controller.dart';

class SignUpOverlay extends StatefulWidget {
  const SignUpOverlay({super.key});

  @override
  State<SignUpOverlay> createState() => _SignUpOverlayState();
}

class _SignUpOverlayState extends State<SignUpOverlay> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
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
    final controller = Get.put(SignUpController());
    final size = MediaQuery.of(context).size;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'Eng',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/logo.png',
                    width: size.width * 0.9,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 33),
                  Text(
                    'Create EPA PASS Account',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 26),


                  // Full Name Input
                  TextField(
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    style: GoogleFonts.poppins(fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person_outline, color: darkText),
                      hintText: 'Full Name',
                      hintStyle: GoogleFonts.poppins(color: hintText, fontSize: 15),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: borderColor, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: borderColor, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: greenColor, width: 1.4),
                      ),
                    ),
                    onChanged: (v) => controller.fullName.value = v,
                  ),
                  const SizedBox(height: 16),

                  // Phone Input
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.poppins(fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.phone_outlined, color: darkText),
                      hintText: 'Phone number',
                      hintStyle: GoogleFonts.poppins(color: hintText, fontSize: 15),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: borderColor, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: borderColor, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: greenColor, width: 1.4),
                      ),
                    ),
                    onChanged: (v) => controller.phoneNumber.value = v,
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: GoogleFonts.poppins(fontSize: 15),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline, color: darkText),
                      hintText: 'Password',
                      hintStyle: GoogleFonts.poppins(color: hintText, fontSize: 15),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: hintText,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: borderColor, width: 1.2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: borderColor, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: greenColor, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  
                  const SizedBox(height: 80),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
