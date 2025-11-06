import 'package:carousel_slider/carousel_slider.dart';
import 'package:eprs/app/modules/home/controllers/home_controller.dart';
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
          final current = controller.currentCarouselIndex.value;
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
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black87, Colors.transparent],
                              ),
                            ),
                            child: Text(
                              caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
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
                      ? const Color(0xFF22C55E)
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
