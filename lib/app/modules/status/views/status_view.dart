import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/status_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';

class StatusView extends GetView<StatusController> {
  const StatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1F8),
      appBar: const CustomAppBar(title: 'Status', subtitle: 'Help improve your community', showBack: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            children: [
              // Segmented control
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))],
                ),
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('All Reports', style: TextStyle(fontWeight: FontWeight.w600))),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Color(0xFFF0EFF6), borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('Closed', style: TextStyle(fontWeight: FontWeight.w600))),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Reports list
              Expanded(
                child: ListView(
                  children: [
                    _reportCard(
                      title: 'Air pollution',
                      id: '171019EA32',
                      status: 'Waiting',
                      statusColor: Colors.grey,
                      description: 'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location].',
                      date: 'June 29, 2023 12:00',
                    ),
                    _reportCard(
                      title: 'water pollution',
                      id: '171019EA32',
                      status: 'In Progress',
                      statusColor: Colors.orange,
                      description: 'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean.',
                      date: 'June 29, 2023 12:00',
                    ),
                    _reportCard(
                      title: 'Air pollution',
                      id: '171019EA32',
                      status: 'Closed',
                      statusColor: Colors.green,
                      description: 'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean.',
                      date: 'June 29, 2023 12:00',
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _reportCard({required String title, required String id, required String status, required Color statusColor, required String description, required String date}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.report_problem_outlined, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                    child: Text('ID: $id', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(description, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 14),
              Align(alignment: Alignment.bottomRight, child: Text(date, style: TextStyle(color: Colors.grey[500]))),
            ],
          ),
        ),
      ),
    );
  }
}
