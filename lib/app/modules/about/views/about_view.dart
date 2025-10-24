import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/about_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final paragraphStyle = TextStyle(color: Colors.deepPurple[600], height: 1.5);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F8),
      appBar: const CustomAppBar(
        title: 'About Us',
        subtitle: 'Help improve your community',
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Image.asset(
                    'assets/logo.png',
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '1. Introduction',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Clean Ethiopia is a digital initiative by the Environmental Protection Authority (EPA) designed to make environmental protection accessible to everyone. Our goal is simple — to empower citizens to report pollution, illegal waste disposal, deforestation, and other environmental violations directly from their mobile devices.',
                style: paragraphStyle,
              ),

              const SizedBox(height: 12),
              Text(
                'We believe that protecting the environment starts with awareness and participation. Through technology, Clean Ethiopia connects the public with the Environmental Protection Authority, ensuring that every report is seen, tracked, and acted upon.',
                style: paragraphStyle,
              ),

              const SizedBox(height: 12),
              Text(
                'Our system promotes:',
                style: paragraphStyle,
              ),
              const SizedBox(height: 8),
              _bullet('Transparency — Every report is traceable from submission to resolution.', paragraphStyle),
              _bullet('Accountability — Each action is logged and monitored to ensure proper follow-up.', paragraphStyle),
              _bullet('Community Engagement — Citizens, communities, and institutions collaborate to keep Ethiopia clean and green.', paragraphStyle),

              const SizedBox(height: 12),
              Text(
                'Clean Ethiopia is part of the nation’s effort to build a sustainable, safe, and environmentally responsible future for all Ethiopians. Together, we can create a cleaner and greener Ethiopia — one report at a time.',
                style: paragraphStyle,
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _bullet(String text, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 12, top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.deepPurpleAccent),
          ),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
