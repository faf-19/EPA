import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/language_controller.dart';
import '../../bottom_nav/views/bottom_nav_view.dart';



class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = [
      'English',
      'Amharic',
      'Afaan Oromo',
      'Tigrigna',
      'Somali',
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Language', subtitle: 'Help improve your community'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: languages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(languages[index]),
                  onTap: () {
                    // TODO: save language selection
                    Get.back();
                  },
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
