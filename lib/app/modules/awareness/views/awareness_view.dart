import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/awareness_controller.dart';
import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';

class AwarenessView extends GetView<AwarenessController> {
  const AwarenessView({super.key});

  @override
  Widget build(BuildContext context) {
    // Non-overlapping layout: banner then card below it
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F8),
      body: SafeArea(
        child: Column(
          children: [
            // Banner (no overlap)
            SizedBox(
              height: 450,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/awareness.png',
                      fit: BoxFit.cover,
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
                          onTap: () => Get.back(),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
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
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Help improve your community',
                              style: TextStyle(
                                color: Colors.black54,
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

            // White card directly under banner (no overlap)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFFF3E8FF),
                            child: Text('👷', style: TextStyle(fontSize: 20)),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tensae Tefera',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                    
                  ),
                  
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text(
                        'Awareness',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Clean Ethiopia ("we," "our," "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard the information you provide when using our mobile application or web system. By using this app, you agree to the terms of this Privacy Policy.',
                        style: TextStyle(
                          color: Color(0xFF5D5A6B),
                          height: 1.6,
                          fontSize: 13,
                        ),
                      ),
              ],)
            // const SizedBox(height: 12),
                      
            ),
            // List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (c, i) {
                    return Row(
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
