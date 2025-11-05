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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(
        title: 'Complain Status',
        subtitle: 'Help improve your community',
        showBack: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterButton('All', isActive: true),
                  const SizedBox(width: 8),
                  _filterButton('Pending'),
                  const SizedBox(width: 8),
                  _filterButton('In Progress'),
                  const SizedBox(width: 8),
                  _filterButton('Completed'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List of Complaints
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _complaintCard(
                    title: 'Family Registration',
                    status: 'Pending',
                    statusColor: Colors.grey,
                    description:
                        'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
                    date: 'June 29, 2025 12:00 AM',
                  ),
                  _complaintCard(
                    title: 'Resident ID',
                    status: 'In Progress',
                    statusColor: Colors.orange,
                    description:
                        'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
                    date: 'June 29, 2025 12:00 AM',
                  ),
                  _complaintCard(
                    title: 'Resident Transfer',
                    status: 'Completed',
                    statusColor: const Color(0xFF16A34A),
                    description:
                        'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
                    date: 'June 29, 2025 12:00 AM',
                  ),
                  _complaintCard(
                    title: 'Unmarried',
                    status: 'Completed',
                    statusColor: const Color(0xFF16A34A),
                    description:
                        'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
                    date: 'June 29, 2025 12:00 AM',
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  // Filter Button
  Widget _filterButton(String label, {bool isActive = false}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          isActive = !isActive;
        },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF16A34A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? const Color(0xFF16A34A) : const Color(0xFFE0E0E0)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    )
    );
  }

  // Complaint Card
  Widget _complaintCard({
    required String title,
    required String status,
    required Color statusColor,
    required String description,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F8E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_none, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            description,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Date
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              date,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
