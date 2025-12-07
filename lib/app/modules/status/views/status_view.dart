import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/status_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'status_detail_view.dart';
// Bottom nav is provided by the app shell; don't import it in this page.

class StatusView extends GetView<StatusController> {
  const StatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: const CustomAppBar(
          title: 'Report Status',
          showBack: true,
          forceHomeOnBack: true,
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

            // List of Complaints (reactive: shows filteredReports from controller)
            Expanded(
              child: Obx(() {
                // Show loading indicator
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Show error message
                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => controller.refreshComplaints(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final reports = controller.filteredReports;
                if (reports.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reports found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => controller.refreshComplaints(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: reports.length + 1, // extra spacer at end
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      if (index == reports.length) return const SizedBox(height: 80);
                      final r = reports[index];
                      return _complaintCard(
                        report: r,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
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

  // Complaint Card — updated to match the design in the provided image
  Widget _complaintCard({
  required ReportItem report,
}) {
  final title = report.title;
  final status = report.status;
  final description = report.description;
  final date = report.date;
  // STATUS COLORS
  Color pillBg;
  Color pillText;

  switch (status.toLowerCase()) {
    case "in progress":
      pillBg = const Color(0xFFF7941D);
      pillText = AppColors.onPrimary;
      break;
    case "completed":
      pillBg = const Color(0xFF00A650);
      pillText = AppColors.onPrimary;
      break;
    case "rejected":
      pillBg = const Color(0xFFFF383C);
      pillText = AppColors.onPrimary;
      break;
    default: // Pending
      pillBg = const Color(0xFFAAAAAA);
      pillText = AppColors.onPrimary; {}
  }

  const outerGlow = Color(0xFFE8F1FF);

  return InkWell(
    onTap: () {
      Get.to(() => StatusDetailView(report: report));
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(top: 16, bottom: 16, left: 13, right: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: outerGlow.withOpacity(0.8),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TITLE + STATUS BADGE
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: pillText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // DATE + TIME ROW
        Row(
          children: [
            // DATE BOX
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8EF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today,
                  color: Color(0xFF1E9B47), size: 16),
            ),
            const SizedBox(width: 10),

            // DATE TEXT
            Text(
              date,
              style: const TextStyle(
                color: Color(0xFF5A5F66),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // DESCRIPTION
        Text(
          description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF8A8F95),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    ),
    ),
  );
}
}