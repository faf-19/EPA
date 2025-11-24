// ─────────────────────────────────────────────────────────────────────────────
//  home_view.dart
// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav is implemented as a separate shell. Do not import the shell here to avoid
// recursive widget construction (the shell instantiates these pages).
import 'package:eprs/app/modules/home/controllers/home_controller.dart';
import 'package:eprs/app/modules/home/widgets/carousel_banner.dart';
import 'package:eprs/core/theme/app_colors.dart';
// quick_actions and status_checker widgets were intentionally removed from
// this view to match the requested layout; keep their files intact in the
// project in case other screens use them.
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // Carousel page controller
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
            // Header (green banner like the design)
            _buildHeader(), 

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  CarouselBanner(
                    carouselController: controller.carouselCtrl,
                    controller: controller,
                  ),
                  const SizedBox(height: 20),

                  // Check Your Status section (custom card)
                  _buildCheckStatusSection(),
                  const SizedBox(height: 20),

                  // Report grid
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF134E4A))),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: const [
                          _ReportTile(image: "assets/pollution.png"),
                          _ReportTile(image: "assets/waste.png"),
                          _ReportTile(image: "assets/chemical.png"),
                          _ReportTile(image: "assets/sound.png"),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                ]),
              ),
            ),
          ],
        ),
      ),
  // BottomNavBar is provided by the top-level shell. Do not include it here.
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String image;

  const _ReportTile({required this.image});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.onPrimary,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

 Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 60, // Reduced height for header
        padding: const EdgeInsets.symmetric(horizontal: 14), // Add horizontal padding
        child: Stack(
          children: [
          // Welcome Yeshak Mesfin text positioned at top left
          Positioned(
            top: 20,
            left: 15, // Position from container start
            right: 120, // Leave space for icons on the right
            child: SizedBox(
              height: 20,
              child: Text(
                'Welcome, Yeshak Mesfin',
                // style: AppFonts.bodyText1Style.copyWith(
                //   fontWeight: AppFonts.medium,
                //   color: AppColors.primary,
                // ),
                overflow: TextOverflow.ellipsis, // Handle text overflow
                maxLines: 1,
              ),
            ),
          ),

          // Notification icon positioned at specified location
          Positioned(
            top: 20,
            right: 50, // Position from right edge
            child: SizedBox(
              width: 18,
              height: 18,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Remove default constraints
                icon: Icon(
                  Icons.notifications,
                  color: AppColors.primary,
                  size: 18,
                ),
                onPressed: () {
                  Get.snackbar('Notifications', 'Coming soon!');
                },
              ),
            ),
          ),

          // Language selector positioned at specified location
          Positioned(
            top: 10, // Adjusted for smaller header
            right: 0, // Position from right edge
            child: SizedBox(
              width: 45,
              height: 35,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    // Text(
                    //   'En',
                    //   style: TextStyle(
                    //     fontFamily: 'Montserrat',
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.w500,
                    //     color: const Color(0xFF073C59),
                    //     ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

   Widget _buildCheckStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Check Your Status" title
        Text(
          'Check Your Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.tertiary,
          ),
        ),
        const SizedBox(height: 16),
        
        // White card with rounded corners containing the search section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Enter Code" label
              Text(
                'Enter Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 12),
              
              // Text field with trailing icon
              Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'MB XXXXXXXX ET',
                          hintStyle: TextStyle(
                            color: AppColors.tertiary.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search,
                      color: AppColors.tertiary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }