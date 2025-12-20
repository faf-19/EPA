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
                            report.reportType ?? 'N/A',
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
    final normalized = status.toLowerCase();
    switch (normalized) {
      case 'under review':
        return const Color(0xFF3F8ECF);
      case 'verified':
        return const Color(0xFF1E88E5);
      case 'under investigation':
      case 'under_investigation':
        return const Color.fromRGBO(59, 161, 245, 1);
      case 'complete':
      case 'completed':
      case 'closed':
        return const Color.fromRGBO(55, 165, 55, 1);
      case 'closed by penality':
        return const Color(0xFFE04343);
      case 'closed by pollutant not found':
        return const Color(0xFFAAAAAA);
      case 'rejected':
        return const Color.fromRGBO(245, 46, 50, 1);
      default: // Pending
        return const Color.fromRGBO(255, 174, 65, 1);
    }
  }

  Widget _buildTimeline() {
    final status = report.status.toLowerCase();
    final normalizedStatus = status.replaceAll('_', ' ');
    final isRejected = status == 'rejected';
    
    final baseDateTimeLabel = _buildDateTimeLabel(report.date, report.time);

    // Define timeline stages
    final stages = [
      {
        'name': 'Pending',
        'date': baseDateTimeLabel,
      },
      {'name': 'Under Review'},
      {'name': 'Verified'},
      {'name': 'Under Investigation'},
      {'name': isRejected ? 'Rejected' : 'Complete'},
    ];

    // Determine which stages are completed based on status
    int completedStages = 0;
    int activeStageIndex = -1;
    
    switch (normalizedStatus) {
      case 'pending':
        completedStages = 0;
        activeStageIndex = 0; // Pending is active
        break;
      case 'under review':
        completedStages = 1; // Pending completed
        activeStageIndex = 1; // Under Review is active
        break;
      case 'verified':
        completedStages = 2; // Pending and Under Review completed
        activeStageIndex = 2; // Verified is active
        break;
      case 'under investigation':
        completedStages = 3; // Pending, Under Review, Verified completed
        activeStageIndex = 3; // Under Investigation is active
        break;
      case 'complete':
        completedStages = 5; // All stages completed
        activeStageIndex = -1;
        break;
      case 'rejected':
        completedStages = 5; // All stages completed, but last one is rejected
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
                      ? Center(
                          child: Transform.scale(
                            scale: 1.5,
                            child: SizedBox.square(
                              dimension: 16,
                              child: Image.asset(
                                'assets/progress.png',
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
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
                  if ((stage['date'] ?? (isCompleted ? baseDateTimeLabel : null)) != null)
                    Text(
                      (stage['date'] ?? baseDateTimeLabel)!,
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

String _buildDateTimeLabel(String date, String? time) {
  final trimmedTime = time?.trim() ?? '';
  if (trimmedTime.isEmpty) return date;
  return '$trimmedTime · $date';
}

