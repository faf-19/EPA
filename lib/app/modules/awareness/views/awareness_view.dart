import 'package:eprs/app/modules/bottom_nav/controllers/bottom_nav_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:eprs/data/models/awareness_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/awareness_controller.dart';
// BottomNavBar provided by app shell; do not include here to prevent recursion.

class AwarenessView extends GetView<AwarenessController> {
  const AwarenessView({super.key});
  
  /// Build network image with fallback URL patterns
  Widget _buildNetworkImageWithFallback(String primaryUrl, AwarenessModel awareness, double size) {
    // For now, just use the primary URL
    // If it fails, we'll need to check with backend team about the correct route
    return Image.network(
      primaryUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (c, e, s) {
        return Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: size * 0.4,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
    // Responsive dimensions
    final bannerHeight = isTablet ? size.height * 0.4 : 420.0;
    final imageSize = isTablet ? 110.0 : 72.0;
    final horizontalPadding = isTablet ? 32.0 : 16.0;
    final titleFontSize = isTablet ? 16.0 : 11.0;
    final descFontSize = isTablet ? 13.0 : 10.0;
    final headerTitleSize = isTablet ? 20.0 : 14.0;
    final headerSubSize = isTablet ? 16.0 : 13.0;
    final backIconSize = isTablet ? 28.0 : 23.0;

    // Non-overlapping layout: banner then card below it
    return Scaffold(
      backgroundColor: AppColors.onPrimary,
      body: SafeArea(
        // Make the whole page scrollable so the banner, cards and list
        // can all fit on smaller devices without overflow.
        child: RefreshIndicator(
          onRefresh: () => controller.loadAwareness(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner (no overlap)
              SizedBox(
                height: bannerHeight,
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
                      height: bannerHeight * 0.3, // Dynamic gradient height
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
                      left: isTablet ? 24 : 12,
                      bottom: isTablet ? 32 : 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () { 
                              Get.find<BottomNavController>().resetToHome();
                              },
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.onPrimary,
                              size: backIconSize,
                            ),
                          ),
                          SizedBox(width: isTablet ? 16 : 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Awareness',
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: headerTitleSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Help improve your community',
                                style: TextStyle(
                                  color: AppColors.onPrimary,
                                  fontSize: headerSubSize,
                                  fontWeight: FontWeight.w700,
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
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value ?? 'An error occurred',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.loadAwareness(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.awarenessList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No awareness items available',
                        style: TextStyle(
                          color: Color(0xFF5D5A6B),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8.0),
                  child: Column(
                    children: List.generate(controller.awarenessList.length, (i) {
                      final awareness = controller.awarenessList[i];
                      final imageUrl = controller.getImageUrl(awareness);
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: i == controller.awarenessList.length - 1 ? 24.0 : 18.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: imageSize,
                              height: imageSize,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imageUrl.isNotEmpty
                                    ? _buildNetworkImageWithFallback(imageUrl, awareness, imageSize)
                                    : Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: imageSize * 0.4,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 20 : 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    awareness.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: titleFontSize,
                                      color: const Color.fromRGBO(0, 0, 0, 1),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    awareness.awarenessDescription,
                                    style: TextStyle(
                                      color: const Color.fromRGBO(99, 85, 127, 1),
                                      height: 1.45,
                                      fontSize: descFontSize,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
        ),
      ),
      // Bottom nav provided by app shell; remove the nested bar here.
    );
  }
}
