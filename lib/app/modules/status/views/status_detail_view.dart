import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../controllers/status_controller.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/core/theme/app_fonts.dart';

class StatusDetailView extends StatelessWidget {
  final ReportItem report;

  const StatusDetailView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(
        title: 'Report Status',
        showBack: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8F1FF).withOpacity(0.8),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and badges row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title (left side)
                        Expanded(
                          child: Text(
                            report.title,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // ID Badge (Blue) - Use report_id
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0047BA),
                            // borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'ID: ${report.reportId ?? report.id ?? 'N/A'}',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(report.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            report.status,
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      report.description,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 14,
                        color: const Color(0xFF8A8F95),
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Green divider line
                    Container(
                      height: 1,
                      color: AppColors.primary,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Timeline
                    _buildTimeline(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return const Color(0xFFF7941D);
      case 'completed':
        return const Color(0xFF00A650);
      case 'rejected':
        return const Color(0xFFFF383C);
      default: // Pending
        return const Color(0xFFAAAAAA);
    }
  }

  Widget _buildTimeline() {
    final status = report.status.toLowerCase();
    final isRejected = status == 'rejected';
    
    // Define timeline stages
    final stages = [
      {'name': 'Pending', 'date': report.date},
      {'name': 'Verified', 'date': report.date},
      {'name': 'Under Investigation', 'date': report.date},
      {'name': isRejected ? 'Closed' : 'Closed by Penalty', 'date': report.date},
    ];

    // Determine which stages are completed based on status
    int completedStages = 0;
    int activeStageIndex = -1;
    
    switch (status) {
      case 'pending':
        completedStages = 0;
        activeStageIndex = 0; // Pending is active
        break;
      case 'in progress':
        completedStages = 1; // Pending completed
        activeStageIndex = 1; // Verified is active
        break;
      case 'verified':
        completedStages = 2; // Pending and Verified completed
        activeStageIndex = 2; // Under Investigation is active
        break;
      case 'completed':
        completedStages = 4; // All stages completed
        activeStageIndex = -1;
        break;
      case 'rejected':
        completedStages = 4; // All stages completed, but last one is rejected (red)
        activeStageIndex = -1;
        break;
      default:
        completedStages = 0;
        activeStageIndex = -1;
    }

    return Column(
      children: List.generate(stages.length, (index) {
        final stage = stages[index];
        final isCompleted = index < completedStages;
        final isCurrent = index == activeStageIndex;
        final isLast = index == stages.length - 1;
        final showRejectionMessage = isRejected && isLast && isCompleted;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                // Circle icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? (isRejected && isLast ? Colors.red : AppColors.primary)
                        : (isCurrent ? AppColors.primary : const Color(0xFFE0E0E0)),
                  ),
                  child: isCurrent && !isCompleted
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : isCompleted
                          ? Icon(
                              isRejected && isLast ? Icons.close : Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                ),
                // Vertical line
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: isCompleted
                        ? AppColors.primary
                        : const Color(0xFFE0E0E0),
                  ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Stage content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage['name']!,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isCurrent
                          ? Colors.black
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                  if (isCurrent && !isCompleted) // Show message for active stage
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'We are preparing your Doc with care',
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  if (showRejectionMessage) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.description,
                        style: TextStyle(
                          fontFamily: AppFonts.primaryFont,
                          fontSize: 12,
                          color: const Color(0xFF8A8F95),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    stage['date']!,
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      fontSize: 12,
                      color: isCompleted || isCurrent
                          ? (isRejected && isLast ? Colors.grey : AppColors.primary)
                          : const Color(0xFFAAAAAA),
                    ),
                  ),
                  if (!isLast) const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

