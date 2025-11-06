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

            // Filter Tabs (compact pill chips matching screenshot)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(() {
                final sel = controller.selectedFilter.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 6),
                        _filterChip('All', sel == 'All'),
                        const SizedBox(width: 10),
                        _filterChip('Pending', sel == 'Pending'),
                        const SizedBox(width: 10),
                        _filterChip('In Progress', sel == 'In Progress'),
                        const SizedBox(width: 10),
                        _filterChip('Completed', sel == 'Completed'),
                        const SizedBox(width: 10),
                        _filterChip('Rejected', sel == 'Rejected'),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                );
              }),
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
                  // Rejected item (shows after scrolling)
                  _complaintCard(
                    title: 'Rejected Case',
                    status: 'Rejected',
                    statusColor: Colors.red,
                    description:
                        'This report was reviewed and rejected due to insufficient evidence. If you have additional information, please re-submit with clearer details or photos.',
                    date: 'June 30, 2025 09:15 AM',
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

  // Compact filter chip (matches screenshot chips)
  Widget _filterChip(String label, bool isActive) {
    return InkWell(
      onTap: () => controller.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF16A34A) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
          // border: isActive ? null : Border.all(color: const Color(0xFFECEFF6)),
          // boxShadow: isActive
          //     ? [BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]
          //     : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF333333),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
