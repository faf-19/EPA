// ─────────────────────────────────────────────────────────────────────────────
//  home_view.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';
import 'package:eprs/app/modules/home/controllers/home_controller.dart';
import 'package:eprs/app/modules/home/widgets/carousel_banner.dart';
import 'package:eprs/app/modules/home/widgets/community_feed.dart';
import 'package:eprs/app/modules/home/widgets/help_dialog.dart';
import 'package:eprs/app/modules/home/widgets/quick_actions.dart';
import 'package:eprs/app/modules/home/widgets/status_checker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  // ── Carousel page controller ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Ensure HomeController is available (defensive in case route bindings weren't set)
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
    // If username is passed from auth flow or stored, sync into controller
    try {
      final args = Get.arguments;
      if (args != null && args is Map && args['username'] is String) {
        final argName = args['username'] as String;
        if (argName.isNotEmpty && controller.userName.value != argName) {
          controller.userName.value = argName;
        }
      }
    } catch (_) {}
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              floating: true,
              title: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                          Text(
                            controller.userName.value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: showHelpDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF22C55E),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Color(0xFF22C55E),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  CarouselBanner(
                    carouselController: controller.carouselCtrl,
                    controller: controller,
                  ),
                  const SizedBox(height: 28),
                  const StatusChecker(),
                  const SizedBox(height: 28),
                  const QuickActions(),
                  const SizedBox(height: 28),
                  CommunityFeed(controller: controller),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
