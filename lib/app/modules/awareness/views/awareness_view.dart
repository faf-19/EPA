import 'package:eprs/app/modules/bottom_nav/controllers/bottom_nav_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/awareness_controller.dart';
// BottomNavBar provided by app shell; do not include here to prevent recursion.

class AwarenessView extends GetView<AwarenessController> {
  const AwarenessView({super.key});

  @override
  Widget build(BuildContext context) {
    // Non-overlapping layout: banner then card below it
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F8),
      body: SafeArea(
        // Make the whole page scrollable so the banner, cards and list
        // can all fit on smaller devices without overflow.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner (no overlap)
              SizedBox(
                height: 420,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/awareness.png',
                        fit: BoxFit.fill,
                        alignment: Alignment.topCenter,
                        errorBuilder: (c, e, s) =>
                            Container(color: Colors.grey[300]),
                      ),
                    ),
                    // green gradient at bottom of banner for visual match
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 120,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF10A94E), Color(0x0010A94E)],
                          ),
                        ),
                      ),
                    ),
                    // back arrow + title at bottom-left of banner
                    Positioned(
                      left: 12,
                      bottom: 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () { 
                              Get.find<BottomNavController>().resetToHome();
                              },
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.onPrimary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Awareness',
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Help improve your community',
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              

              

              // List of awareness items recreated as a Column so it participates in
              // the outer SingleChildScrollView (avoids nested scrollables).
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: i == 2 ? 24.0 : 18.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/awareness.png',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    Container(color: Colors.grey[200]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Awareness 1',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Clean Ethiopia ("we," "our," "us") is committed to protecting your privacy. This Privacy Policy explains how we collect,',
                                  style: TextStyle(
                                    color: Color(0xFF5D5A6B),
                                    height: 1.45,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      // Bottom nav provided by app shell; remove the nested bar here.
    );
  }
}
