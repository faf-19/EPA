import 'package:carousel_slider/carousel_slider.dart';
import 'package:eprs/app/modules/home/controllers/home_controller.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CarouselBanner extends StatelessWidget {
  final CarouselSliderController carouselController;
  final HomeController controller;

  const CarouselBanner({
    super.key,
    required this.carouselController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 2),
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              onPageChanged: (index, _) =>
                  controller.currentCarouselIndex.value = index,
            ),
            items: controller.imageUrls.map((url) {
              final caption = controller.imageCaptions[url] ?? '';
              final date = controller.imageDates[url] ?? '';
              final city = controller.imageCities[url] ?? '';
              return Builder(
                builder: (_) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(url, fit: BoxFit.cover),
                        // Top-left: Date and City
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date with dark overlay
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // City in green pill shape
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  city,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bottom: Green gradient with caption
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.primary.withOpacity(0.85),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                            child: Text(
                              caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final current = controller.currentCarouselIndex.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: controller.imageUrls.asMap().entries.map((e) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: e.key == current ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: e.key == current
                      ? AppColors.primary
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
