
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/core/enums/report_type_enum.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:eprs/app/routes/app_pages.dart';

import '../controllers/report_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportView extends StatefulWidget {
  final String reportType;

  const ReportView({super.key, required this.reportType});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  // Get controller instance
  ReportController get controller => Get.find<ReportController>();
  
  @override
  void initState() {
    super.initState();
    // Reset form when view is initialized (when navigating to this page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetForm();
      // Reload necessary data after reset
      controller.loadAuthState(); // Restore phone number if user is logged in
      controller.fetchRegions();
      controller.fetchPollutionCategories();
      if (controller.autoDetectLocation.value) {
        controller.detectLocation();
      }
      if (widget.reportType == ReportTypeEnum.sound.name) {
        controller.fetchSoundAreas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set report type in controller
    controller.reportType = widget.reportType;
    final isSoundReport = widget.reportType == ReportTypeEnum.sound.name;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Report Issue',
        showBack: true,
        forceHomeOnBack: true, // ensure back reliably returns to Home shell
        showHelp: true,
        helpRoute: Routes.FAQ,
      ),
      backgroundColor: const Color(0xFFF6F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Insert this Card ABOVE the Evidence Card ---
              
                Card(
                  color: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Dynamic title & description based on `reportType`
                        Builder(builder: (_) {
                          String title;
                          String desc;
                          switch (widget.reportType) {
                            case 'pollution':
                              title = 'Pollution Description';
                              desc = 'Describe the pollution observed (air, water, or soil), its source, and any visible impact on the environment or public health.';
                              break;
                            case 'waste':
                              title = 'Waste Description';
                              desc = 'Describe the type of waste (household, industrial, construction), exact location, and whether it is actively being dumped or is an abandoned pile.';
                              break;
                            case 'chemical':
                              title = 'Chemical / Hazardous Material Description';
                              desc = 'Provide details on the chemical or hazardous material (labels if visible), estimated quantity, and any immediate danger (smoke, spills, fumes). Avoid close contact.';
                              break;
                            default:
                              title = 'Sound Description';
                              desc = 'Provide a clear description of the issue, including location, time observed, and any other details that can help inspection teams.';
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                desc,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              // Pollution Category Card
                Card(
                  color: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pollution Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.isLoadingPollutionCategories.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.pollutionCategoriesError.value != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.pollutionCategoriesError.value ?? 'Failed to Load Categories',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: controller.fetchPollutionCategories,
                                  child: const Text('Retry'),
                                ),
                              ],
                            );
                          }

                          final relevantItems = isSoundReport
                              ? controller.pollutionCategoriesSound
                              : controller.pollutionCategoriesNormal;

                          String? value = controller.selectedPollutionCategoryId.value;
                          final validValues =
                              relevantItems.map((entry) => entry['id']).whereType<String>().toSet();
                          if (value != null && !validValues.contains(value)) {
                            // Clear stale selection after rebuild to satisfy dropdown constraint
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.selectPollutionCategory(null);
                            });
                            value = null;
                          }

                          if (relevantItems.isEmpty) {
                            return const Text(
                              'No pollution categories available for this report type',
                              style: TextStyle(color: Colors.black54),
                            );
                          }

                          return DropdownButtonFormField<String?>(
                            initialValue: value,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            alignment: AlignmentDirectional.centerStart,
                            itemHeight: 48,
                            menuMaxHeight: 260,
                            borderRadius: BorderRadius.circular(8),
                            items: [
                              
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Select pollution category',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ...relevantItems.map((category) {
                                final id = category['id'];
                                final name = category['name'] ?? '';
                                return DropdownMenuItem<String?>(
                                  value: id,
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }),
                            ],
                            onChanged: controller.selectPollutionCategory,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1.1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Select pollution category',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),


              const SizedBox(height: 12),

              if (isSoundReport)
                Card(
                  color: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Land Use Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (controller.isLoadingSoundAreas.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.soundAreasError.value != null) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.soundAreasError.value ?? 'Failed to load areas',
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: controller.fetchSoundAreas,
                                  child: const Text('Retry'),
                                ),
                              ],
                            );
                          }

                          if (controller.soundAreas.isEmpty) {
                            return const Text(
                              'No sound areas available',
                              style: TextStyle(color: Colors.black54),
                            );
                          }

                          final items = controller.soundAreas;
                          final value = controller.selectedSoundAreaId.value;

                          return DropdownButtonFormField<String?>(
                            initialValue: value,
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            alignment: AlignmentDirectional.centerStart,
                            itemHeight: 48,
                            menuMaxHeight: 260,
                            borderRadius: BorderRadius.circular(8),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text(
                                  'Select sound area',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                              ...items.map(
                                (area) => DropdownMenuItem<String?>(
                                  value: area.id,
                                  child: Text(
                                    area.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: controller.selectSoundArea,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(212, 212, 212, 1),
                                  width: 1.1,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Select sound area',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                if (isSoundReport)
              const SizedBox(height: 12),

              //time of the day card for sound report
              if (widget.reportType == ReportTypeEnum.sound.name)
                Card(
                  color: const Color(0xFFFFFFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time of Day',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87
                          ),
                        ),
                        const SizedBox(height: 12),
                        Obx(() {
                          final current = controller.soundPeriod.value;
                          return Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => controller.soundPeriod.value = 'Day',
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: current == 'Day' ? AppColors.primary : Color.fromRGBO(212, 212, 212, 1),
                                      width: current == 'Day' ? 1.1 : 1,
                                    ),
                                    backgroundColor: current == 'Day' ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Day',
                                    style: TextStyle(
                                      color: current == 'Day' ? AppColors.primary : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => controller.soundPeriod.value = 'Night',
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 14,
                                    ),
                                    side: BorderSide(
                                      color: current == 'Night' ? AppColors.primary : Color.fromRGBO(212, 212, 212, 1),
                                      width: current == 'Night' ? 1.1 : 1,
                                    ),
                                    backgroundColor: current == 'Night' ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Night',
                                    style: TextStyle(
                                      color: current == 'Night' ? AppColors.primary : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              
              // Time & Date Card
              Card(
                color: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Time and Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final d = controller.selectedDate.value;
                              final label = d == null
                                  ? 'Select Date'
                                  : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                              return OutlinedButton(
                                onPressed: () => controller.pickDate(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(color: Color(0xFFD4D4D4)),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: d == null ? Colors.grey.shade600 : Colors.black87,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() {
                              final t = controller.selectedTime.value;
                              String label;
                              if (t == null) {
                                label = 'Select Time';
                              } else {
                                final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
                                final minute = t.minute.toString().padLeft(2, '0');
                                final period = t.period == DayPeriod.am ? 'AM' : 'PM';
                                label = '$hour:$minute $period';
                              }
                              return OutlinedButton(
                                onPressed: () => controller.pickTime(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(color: Color(0xFFD4D4D4)),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: t == null ? Colors.grey.shade600 : Colors.black87,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              // Evidence Card
              Card(
                color: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: Colors.black87,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add Evidence',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Evidence input: voice recorder for sound, tiles for others
                      if (widget.reportType == ReportTypeEnum.sound.name) ...[
                        _buildRecordingUI(context),
                      ] else ...[
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.9,
                          children: [
                            _evidenceTile(
                              context,
                              Icons.camera_alt_outlined,
                              'Photo',
                            ),
                            _evidenceTile(
                              context,
                              Icons.videocam_outlined,
                              'Record Video',
                              isVideo: true,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Obx(() {
                        final imgs = controller.pickedImages;
                        final count = imgs.length;
                        if (count == 0) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF7F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'No files uploaded',
                              style: TextStyle(color: Colors.black87),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 84,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: count,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (ctx, i) {
                                  final xFile = imgs[i];
                                  final fileName = (xFile.name.isNotEmpty
                                          ? xFile.name
                                          : xFile.path.split('/').last)
                                      .toLowerCase();
                                  final isAudio = fileName.endsWith('.m4a') ||
                                      fileName.endsWith('.mp3') ||
                                      fileName.endsWith('.wav') ||
                                      fileName.endsWith('.aac') ||
                                      fileName.contains('voice_note');
                                  final isVideo = fileName.endsWith('.mp4') ||
                                      fileName.endsWith('.mov') ||
                                      fileName.endsWith('.avi') ||
                                      fileName.endsWith('.mkv');
                                  final isImage = fileName.endsWith('.png') ||
                                      fileName.endsWith('.jpg') ||
                                      fileName.endsWith('.jpeg') ||
                                      fileName.endsWith('.gif') ||
                                      fileName.endsWith('.webp');
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 120,
                                          height: 84,
                                          decoration: BoxDecoration(
                                            color: isAudio 
                                                ? const Color(0xFFEFF7F0)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: isAudio
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.audiotrack,
                                                    size: 40,
                                                    color: Color(0xFF63557F),
                                                  ),
                                                )
                                              : isVideo
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons.videocam,
                                                        size: 40,
                                                        color: Color(0xFF63557F),
                                                      ),
                                                    )
                                                  : isImage
                                                      ? FutureBuilder<Uint8List>(
                                                          future: xFile.readAsBytes(),
                                                          builder: (context, snapshot) {
                                                            if (snapshot.hasData) {
                                                              return Image.memory(
                                                                snapshot.data!,
                                                                fit: BoxFit.cover,
                                                              );
                                                            } else if (snapshot.hasError) {
                                                              return const Icon(Icons.image);
                                                            } else {
                                                              return const Center(
                                                                child: CircularProgressIndicator(strokeWidth: 2),
                                                              );
                                                            }
                                                          },
                                                        )
                                                      : const Center(
                                                          child: Icon(
                                                            Icons.insert_drive_file,
                                                            size: 32,
                                                            color: Color(0xFF63557F),
                                                          ),
                                                        ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => controller.removePickedImageAt(i),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$count File(s) Uploaded',
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Location Card
              Card(
                color: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                        children: const [
                          Text(
                            'Are you in the spot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                       ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final isInSpotValue = controller.isInTheSpot.value;
                        final isInSpot = isInSpotValue == true; // Only true if explicitly true
                        final isNotInSpot = isInSpotValue == false; // Only true if explicitly false
                        // If isInSpotValue is null, both isInSpot and isNotInSpot will be false
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  controller.hasSelectedLocationOption.value = true;
                                  controller.isInTheSpot.value = true;
                                  // Clear region/zone/woreda selections when switching to "Yes"
                                  controller.selectedRegion.value = 'Select Region / City Administration';
                                  controller.selectedZone.value = 'Select Zone / Sub-City';
                                  controller.selectedWoreda.value = 'Select Woreda';
                                  controller.zones.clear();
                                  controller.woredas.clear();
                                  
                                  // Auto-enable location toggle when "Yes" is pressed
                                  if (!controller.autoDetectLocation.value) {
                                    await controller.toggleAutoDetect(true);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: isInSpot ? AppColors.primary : Color.fromRGBO(212, 212, 212, 1),
                                    width: isInSpot ? 1.1 : 1,
                                  ),
                                  backgroundColor: isInSpot ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Yes',
                                  style: TextStyle(
                                    color: isInSpot ? AppColors.primary : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  controller.hasSelectedLocationOption.value = true;
                                  controller.isInTheSpot.value = false;
                                  // Clear auto-detect location when switching to "No"
                                  controller.autoDetectLocation.value = false;
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: isNotInSpot ? AppColors.primary : Color.fromRGBO(212, 212, 212, 1),
                                    width: isNotInSpot ? 1.1 : 1,
                                  ),
                                  backgroundColor: isNotInSpot ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                    color: isNotInSpot ? AppColors.primary : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      // Show Location section only when "Yes" is selected
                      Obx(() {
                        if (!controller.hasSelectedLocationOption.value || controller.isInTheSpot.value != true) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: const [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FFF6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: Colors.black54,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Obx(
                                      () => Text(
                                        controller.autoDetectLocation.value
                                            ? controller.detectedAddress.value
                                            : 'Tap Search Location\nAddis Ababa | N.L | W-1',
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                  // Custom ON/OFF pill with label inside (matches design)
                                  Column(children: [_onOffToggle()]),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                      // Region/Zone/Woreda dropdowns; only show when "Are you in the spot" is "No"
                      Obx(() {
                        // Only show dropdowns if user selected "No" for "Are you in the spot"
                        if (!controller.hasSelectedLocationOption.value || controller.isInTheSpot.value != false) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            // Region / City dropdown (populated from API) - always show first
                            Obx(() {
                              final items = controller.regionsAndCities;
                              final names = ['Select Region / City Administration'] + items.map((e) => e['name']!).toList();
                              // Ensure selectedRegion is set to placeholder if not in list
                              if (items.isNotEmpty && !names.contains(controller.selectedRegion.value)) {
                                controller.selectedRegion.value = 'Select Region / City Administration';
                              }
                              return _buildDropdown(
                                'Region / City Administration',
                                names,
                                value: controller.selectedRegion.value,
                                enabled: true,
                                onChanged: (v) {
                                  final selected = v ?? 'Select Region / City Administration';
                                  controller.selectedRegion.value = selected;
                                  // Clear zone and woreda when region changes
                                  controller.selectedZone.value = 'Select Zone / Sub-City';
                                  controller.selectedWoreda.value = 'Select Woreda';
                                  controller.woredas.clear();
                                  
                                  // find id and load zones
                                  final id = controller.findIdByName(controller.regionsAndCities, selected);
                                  final selectedItem = items.where((item) => item['name'] == selected).firstOrNull;
                                  final isRegion = selectedItem?['type'] == 'region';
                                  
                                  print('🔄 Region selected: $selected');
                                  print('   ID: $id');
                                  print('   Is Region: $isRegion');
                                  print('   Selected item: $selectedItem');
                                  
                                  if (id != null && isRegion) {
                                    print('✅ Fetching zones for region ID: $id');
                                    controller.fetchZonesForRegion(id);
                                  } else {
                                    print('⚠️ Not fetching zones - ID: $id, isRegion: $isRegion');
                                    // Clear zones for cities or when nothing is selected
                                    controller.zones.clear();
                                  }
                                },
                              );
                            }),
                            // Zone dropdown - only show when a region is selected
                            Obx(() {
                              // Only show if a region is selected (not the placeholder)
                              final isRegionSelected = controller.selectedRegion.value != 'Select Region / City Administration';
                              if (!isRegionSelected) {
                                return const SizedBox.shrink();
                              }
                              
                              final items = controller.zones;
                              final names = ['Select Zone / Sub-City'] + items.map((e) => e['name']!).toList();
                              
                              // Show loading indicator while fetching zones
                              if (controller.isLoadingZones.value) {
                                return Column(
                                  children: [
                                    const SizedBox(height: 8),
                                    _buildDropdown(
                                      'Zone / Sub-City',
                                      ['Select Zone / Sub-City'],
                                      value: 'Select Zone / Sub-City',
                                      enabled: false,
                                      onChanged: null,
                                    ),
                                    const SizedBox(height: 4),
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              
                              // Ensure selectedZone is set to placeholder if not in list
                              // Use post-frame callback to avoid setState during build
                              if (items.isNotEmpty && !names.contains(controller.selectedZone.value)) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  controller.selectedZone.value = 'Select Zone / Sub-City';
                                });
                              }
                              
                              return Column(
                                children: [
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    'Zone / Sub-City',
                                    names,
                                    value: controller.selectedZone.value,
                                    enabled: items.isNotEmpty, // Disable if no zones available
                                    onChanged: items.isNotEmpty ? (v) {
                                      final selected = v ?? 'Select Zone / Sub-City';
                                      controller.selectedZone.value = selected;
                                      // Clear woreda when zone changes
                                      controller.selectedWoreda.value = 'Select Woreda';
                                      
                                      // find id and load woredas
                                      final id = controller.findIdByName(controller.zones, selected);
                                      if (id != null) {
                                        controller.fetchWoredasForZone(id);
                                      } else {
                                        controller.woredas.clear();
                                      }
                                    } : null,
                                  ),
                                ],
                              );
                            }),
                            // Woreda dropdown - only show when a zone is selected
                            Obx(() {
                              // Only show if a zone is selected (not the placeholder) and woredas are available
                              if (controller.selectedZone.value == 'Select Zone / Sub-City' || 
                                  controller.woredas.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final items = controller.woredas;
                              final names = ['Select Woreda'] + items.map((e) => e['name']!).toList();
                              // Ensure selectedWoreda is set to placeholder if not in list
                              if (items.isNotEmpty && !names.contains(controller.selectedWoreda.value)) {
                                controller.selectedWoreda.value = 'Select Woreda';
                              }
                              return Column(
                                children: [
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    'Woreda',
                                    names,
                                    value: controller.selectedWoreda.value,
                                    enabled: true,
                                    onChanged: (v) => controller.selectedWoreda.value = v ?? 'Select Woreda',
                                  ),
                                ],
                              );
                            }),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),

              // a specific location card
              Card(
                color: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                        children: const [
                          Text(
                            'Specific Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                       ),
                      const SizedBox(height: 12),
                      TextFormField(
                        // controller: controller.descriptionController,
                        
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: 13),
                          fillColor: const Color.fromRGBO(202, 213, 226, 0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color.fromRGBO(212, 212, 212, 1)),
                          ),
                         
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(212, 212, 212, 1),
                              width: 0.4, // 👉 thinner
                            ),
                          ),

                          // Focused border (also missing)
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(212, 212, 212, 1), // green
                              width: 0.8, // slightly thicker fFor visibility
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 12),

              // Description Card
              Card(
                color: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                       ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controller.descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: 13),
                          fillColor: const Color.fromRGBO(202, 213, 226, 0.2),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color.fromRGBO(212, 212, 212, 1)),
                          ),
                         
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(212, 212, 212, 1),
                              width: 0.4, // 👉 thinner
                            ),
                          ),

                          // Focused border (also missing)
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(212, 212, 212, 1), // green
                              width: 0.8, // slightly thicker for visibility
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 12),
              // Phone Number Card

              
              Obx(() => controller.isLoggedIn.value
                  ? const SizedBox.shrink()
                  : Card(
                      color: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                        children: const [
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            '*',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                       ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      // 1. The actual input field
                                      Obx(() {
                                        final isHidden = controller.obscurePhoneNumber.value;
                                        return TextFormField(
                                          controller: controller.phoneController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                          inputFormatters:  [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          // When hidden, make text transparent so overlay can show
                                          style: isHidden
                                              ? GoogleFonts.robotoMono(color: Colors.transparent, fontSize: 16)
                                              : GoogleFonts.robotoMono(color: Colors.black87, fontSize: 16),
                                          cursorColor: Colors.black,
                                          showCursor: true,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Your Phone Number (e.g. 091XXXXXXX)',
                                            hintStyle: const TextStyle(fontSize: 13, color: Colors.black54),
                                            counterText: '',
                                            errorText: null,
                                            errorStyle: const TextStyle(height: 0, fontSize: 0),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(212, 212, 212, 1),
                                                width: 0.5,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(212, 212, 212, 1),
                                                width: 0.4,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromRGBO(212, 212, 212, 1),
                                                width: 0.8,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      
                                      // 2. The Masked Overlay
                                      // Listens to controller changes to update mask in real-time
                                      Positioned.fill(
                                        child: IgnorePointer(
                                          ignoring: true,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 14,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Obx(() {
                                                final isHidden = controller.obscurePhoneNumber.value;
                                                return ValueListenableBuilder<TextEditingValue>(
                                                  valueListenable: controller.phoneController,
                                                  builder: (context, value, child) {
                                                    // Only show overlay if hidden AND not empty
                                                    if (!isHidden || value.text.isEmpty) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    
                                                    final text = value.text;
                                                    String maskedText;
                                                    if (text.length <= 2) {
                                                      maskedText = text;
                                                    } else {
                                                      maskedText = text.substring(0, 2) + '*' * (text.length - 2);
                                                    }

                                                    return Text(
                                                      maskedText,
                                                      style: GoogleFonts.robotoMono(
                                                        color: Colors.black87,
                                                        fontSize: 16, // Must match TextFormField default
                                                      ),
                                                    );
                                                  },
                                                );
                                              }),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Toggle Button
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _onOffToggle(
                                      bound: controller.phoneOptIn,
                                      isPhoneNumber: true,
                                      onChanged: (v) {
                                        // v=true (ON) -> obscure=true (Masked)
                                        // v=false (OFF) -> obscure=false (Visible)
                                        controller.obscurePhoneNumber.value = v;
                                        controller.togglePhoneOptIn(v);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Obx(() {
                              final err = controller.phoneError.value;
                              return SizedBox(
                                height: 18,
                                child: err.isEmpty
                                    ? const SizedBox.shrink()
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          err,
                                          style: const TextStyle(color: Colors.red, fontSize: 12),
                                        ),
                                      ),
                              );
                            }),
                          ],
                        ),
                      ),
                    )),




              const SizedBox(height: 18),

              // Terms checkbox
              Obx(() => Row(
                children: [
                  Checkbox(
                    activeColor: AppColors.primary,
                    value: controller.termsAccepted.value,
                    onChanged: (v) => controller.termsAccepted.value = v ?? false,
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I Agree To The ',
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms And Conditions',
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.toNamed(Routes.TERM_AND_CONDITIONS);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 12),

              // Send button
              Obx(() => SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.submitReport(isSoundReport),
                  style: ButtonStyle(
                    // Keep the button green for all states (including disabled)
                    backgroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
                    foregroundColor: WidgetStateProperty.all<Color>(AppColors.onPrimary),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                          ),
                        )
                      : const Text(
                          'SEND',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _evidenceTile(BuildContext ctx, IconData icon, String label, {bool isVoiceNote = false, bool isVideo = false}) {
    return InkWell(
      onTap: () async {
        if (isVoiceNote) {
          // Start recording immediately when voice note button is pressed
          await controller.startRecording();
          return;
        }

        if (isVideo) {
          // Show video picker options
          final choice = await showModalBottomSheet<int>(
            context: ctx,
            builder: (sheetCtx) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.videocam_outlined),
                      title: const Text('Record a Video'),
                      onTap: () => Navigator.of(sheetCtx).pop(1),
                    ),
                    ListTile(
                      leading: const Icon(Icons.video_library_outlined),
                      title: const Text('Upload from Gallery'),
                      onTap: () => Navigator.of(sheetCtx).pop(2),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );

          if (choice == 1 || choice == 2) {
            showDialog(
              context: ctx,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );
            try {
              if (choice == 1) {
                await controller.pickVideoFromCamera();
              } else {
                await controller.pickVideoFromGallery();
              }
              Get.snackbar(
                'Upload',
                'Video added',
                snackPosition: SnackPosition.BOTTOM,
              );
            } catch (e) {
              Get.snackbar(
                'Upload failed',
                e.toString(),
                snackPosition: SnackPosition.BOTTOM,
              );
            } finally {
              try {
                Navigator.of(ctx, rootNavigator: true).pop();
              } catch (_) {}
            }
          }
          return;
        }

        // Photo picker
        final choice = await showModalBottomSheet<int>(
          context: ctx,
          builder: (sheetCtx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt_outlined),
                    title: const Text('Take Photo'),
                    onTap: () => Navigator.of(sheetCtx).pop(1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('Upload from Gallery'),
                    onTap: () => Navigator.of(sheetCtx).pop(2),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );

        if (choice == 1 || choice == 2) {
          // show a small progress indicator while the picker runs
          showDialog(
            context: ctx,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          try {
            if (choice == 1) {
              await controller.pickFromCamera();
            } else {
              await controller.pickFromGallery();
            }
            // optional: brief success feedback
            Get.snackbar(
              'Upload',
              'File added',
              snackPosition: SnackPosition.BOTTOM,
            );
          } catch (e) {
            Get.snackbar(
              'Upload failed',
              e.toString(),
              snackPosition: SnackPosition.BOTTOM,
            );
          } finally {
            // close the progress dialog
            try {
              Navigator.of(ctx, rootNavigator: true).pop();
            } catch (_) {}
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // make the dashed box responsive to available width; keep a sensible min height
          final boxHeight = (constraints.maxWidth * 0.5).clamp(64.0, 120.0);
          return DashedBorder(
            child: Container(
              height: boxHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 28, color: const Color(0xFF63557F)),
                    const SizedBox(height: 8),
                    Text(label, style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingUI(BuildContext context) {
    // Build waveform outside Obx to keep it stable
    final waveformWidget = _buildSoundGauge();
    
    return Obx(() {
      final duration = controller.recordingDuration.value;
      final isPaused = controller.isPaused.value;
      final isRecording = controller.isRecording.value;
      final isWeb = kIsWeb;

      // Idle state: show start prompt instead of auto-starting
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color.fromRGBO(212, 212, 212, 1), width: 0.4),
        ),
        child: Column(
          children: [
            if (isWeb)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recording not supported in web. Please use Android/iOS.',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            if (isWeb) const SizedBox(height: 12),
            // Waveform visualization - built outside Obx to keep it stable
            waveformWidget,
            const SizedBox(height: 16),
            // Frequency and Duration display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  final decibel = controller.isRecording.value 
                      ? controller.currentDecibel.value 
                      : 0.0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Frequency ${decibel.toStringAsFixed(1)}db',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Duration ${controller.formatDuration(duration)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Three buttons: Stop, Cancel, Start/Pause/Resume
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                // Cancel button
                _buildRecordingButton(
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                  color: (isRecording || isPaused) && !isWeb
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  enabled: (isRecording || isPaused) && !isWeb && !controller.isCanceling.value,
                  onPressed: () {
                    if (controller.isCanceling.value) return;
                    controller.cancelRecording().catchError((error) {
                      print('Error canceling recording: $error');
                      Get.snackbar(
                        'Error',
                        'Failed to cancel recording: ${error.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                ),

                // Pause/Resume button
                _buildRecordingButton(
                  icon: isRecording
                      ? (isPaused ? Icons.play_arrow : Icons.pause)
                      : Icons.mic,
                  label: isRecording
                      ? (isPaused ? 'Resume' : 'Pause')
                      : 'Start',
                  color: isWeb ? Colors.grey.shade400 : AppColors.primary,
                  enabled: !isWeb,
                  onPressed: () {
                    if (isWeb) return;
                    if (!isRecording) {
                      controller.startRecording();
                    } else if (isPaused) {
                      controller.resumeRecording();
                    } else {
                      controller.pauseRecording();
                    }
                  },
                ),

                // Stop button
                _buildRecordingButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  color: (isRecording || isPaused) && !isWeb
                      ? AppColors.primary
                      : Colors.grey.shade400,
                  enabled: (isRecording || isPaused) && !isWeb && !controller.isStopping.value,
                  onPressed: () {
                    if (controller.isStopping.value) return;
                    controller.stopRecording().catchError((error) {
                      print('Error stopping recording: $error');
                      Get.snackbar(
                        'Error',
                        'Failed to stop recording: ${error.toString()}',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    });
                  },
                ),  
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSoundGauge() {
    // Speedometer-like gauge driven by current decibel (0–100 dB)
    return Obx(() {
      final isRecording = controller.isRecording.value;
      final isPaused = controller.isPaused.value;
      final db = isRecording ? controller.currentDecibel.value : 0.0;

      return SizedBox(
        height: 120,
        width: double.infinity,
        child: CustomPaint(
          painter: _SoundGaugePainter(
            value: db,
            min: 0,
            max: 100,
            active: isRecording && !isPaused,
          ),
        ),
      );
    });
  }

  Widget _buildRecordingButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: enabled ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: enabled
                ? () {
                    try {
                      onPressed();
                    } catch (e) {
                      print('Error in recording button callback: $e');
                    }
                  }
                : null,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? color : Colors.grey.shade300,
              ),
              child: Icon(
                icon,
                color: enabled ? Colors.white : Colors.white70,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items, {
    required String value,
    required bool enabled,
    required ValueChanged<String?>? onChanged,
  }) {
    // Ensure the current value is in the items list
    // If value is not in items, use the first item (placeholder) if available
    final currentValue = items.isNotEmpty
        ? (items.contains(value) ? value : items.first)
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          key: ValueKey('${label}_${items.length}'),
          initialValue: currentValue,
          dropdownColor: Colors.white,
          items: items.isEmpty
              ? null
              : items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ))
                  .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromRGBO(212, 212, 212, 1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromRGBO(212, 212, 212, 1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Color.fromRGBO(212, 212, 212, 1),
                width: 1,
              ),
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            hintText: items.isNotEmpty ? items.first : label,
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          isExpanded: true,
          menuMaxHeight: 260,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  /// Custom rounded toggle with internal ON/OFF label to match the design.
  // Generic toggle widget. If [bound] is provided it will control that
  // observable; otherwise it defaults to controlling the location auto-detect.
  Widget _onOffToggle({
    RxBool? bound,
    bool isPhoneNumber = false,
    void Function(bool)? onChanged,
  }) {
    return Obx(() {
      final rx = bound ?? controller.autoDetectLocation;
      final isOn = rx.value;
      return GestureDetector(
        onTap: () async {
          final newVal = !isOn;
          if (onChanged != null) {
            onChanged(newVal);
          } else if (bound != null) {
            bound.value = newVal;
          } else {
            // For location toggle, request permission when turning ON
            await controller.toggleAutoDetect(newVal);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 92,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isOn ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // label (ON / OFF) positioned on the opposite side of the thumb
              Align(
                alignment: isOn ? Alignment.centerLeft : Alignment.centerRight,
                child: Padding(
                  padding: isOn
                      ? const EdgeInsets.only(left: 8.0)
                      : const EdgeInsets.only(right: 8.0),
                  child: isPhoneNumber
                      ? Text(
                          isOn ? 'HIDE' : 'SHOW',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          isOn ? 'ON' : 'OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              // thumb
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// /// Draws a rounded dashed border around [child].
class DashedBorder extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final BorderRadius borderRadius;

  const DashedBorder({
    super.key,
    required this.child,
    this.strokeWidth = 1.5,
    this.dashWidth = 6,
    this.dashSpace = 6,
    this.color = const Color(0xFFBFCFE0),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        color: color,
        borderRadius: borderRadius,
      ),
      child: Padding(padding: const EdgeInsets.all(4.0), child: child),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final Color color;
  final BorderRadius borderRadius;

  _DashedRectPainter({
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          end.clamp(0.0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = distance + dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom waveform painter that creates animated waves based on audio amplitude
// Uses decibel readings from noise meter to create real-time visualization
class _WaveformPainter extends CustomPainter {
  final double amplitude;
  final Color color;
  final bool isActive;
  static final List<double> _waveData = List.generate(60, (_) => 0.0);

  _WaveformPainter({
    required this.amplitude,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) {
      // Draw flat line when not recording
      final paint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    // Update wave data with new amplitude
    _waveData.removeAt(0);
    _waveData.add(amplitude);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final barWidth = size.width / _waveData.length;
    final maxHeight = size.height * 0.45;

    // Draw waveform bars with spacing
    for (int i = 0; i < _waveData.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final barHeight = _waveData[i] * maxHeight;
      
      // Add minimum height for visibility
      final minHeight = maxHeight * 0.1;
      final finalHeight = barHeight < minHeight ? minHeight : barHeight;
      
      // Draw top bar
      canvas.drawLine(
        Offset(x, centerY - finalHeight),
        Offset(x, centerY),
        paint,
      );
      
      // Draw bottom bar (mirrored)
      canvas.drawLine(
        Offset(x, centerY),
        Offset(x, centerY + finalHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.color != color ||
        oldDelegate.isActive != isActive;
  }
}

// Sound gauge painter: draws semicircle segments and an animated needle.
class _SoundGaugePainter extends CustomPainter {
  final double value; // current dB
  final double min;
  final double max;
  final bool active;

  _SoundGaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height * 0.9);
    final radius = math.min(width, height * 2) * 0.42;

    final baseRect = Rect.fromCircle(center: center, radius: radius);
    const start = math.pi; // left
    const sweep = math.pi; // semicircle

    // Track style
    final trackWidth = math.max(8.0, radius * 0.12);
    final separatorWidth = trackWidth * 0.22;

    // Segment colors: green → lightGreen → yellow → orange → red
    final segments = <Color>[
      const Color(0xFF1EAD3D),
      const Color(0xFF90C33F),
      const Color(0xFFFFD63A),
      const Color(0xFFF08A27),
      const Color(0xFFE53935),
    ];

    // Draw segments
    final segCount = segments.length;
    final segSweep = sweep / segCount;
    for (int i = 0; i < segCount; i++) {
      final segPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth
        ..strokeCap = StrokeCap.butt
        ..color = segments[i];

      // add small gap between segments to mimic the image
      final gap = separatorWidth / radius; // radians approximation
      final segStart = start + i * segSweep + (i == 0 ? 0 : gap);
      final segEnd = start + (i + 1) * segSweep - (i == segCount - 1 ? 0 : gap);
      final segAngle = segEnd - segStart;
      canvas.drawArc(baseRect, segStart, segAngle, false, segPaint);
    }

    // Optional: inner thin grey arc for ticks
    final ticksPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFB0BEC5);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.78),
      start,
      sweep,
      false,
      ticksPaint,
    );

    // Draw tick marks every 10 dB
    for (int t = min.round(); t <= max.round(); t += 10) {
      final ratio = (t - min) / (max - min);
      final angle = start + ratio * sweep;
      final p1 = _polar(center, radius * 0.74, angle);
      final p2 = _polar(center, radius * 0.82, angle);
      final tp = Paint()
        ..color = const Color(0xFF90A4AE)
        ..strokeWidth = t % 20 == 0 ? 2.0 : 1.2;
      canvas.drawLine(p1, p2, tp);
    }

    // Needle
    final clamped = value.isNaN ? min : value.clamp(min, max);
    final ratio = (clamped - min) / (max - min);
    final angle = start + ratio * sweep;
    final needleLen = radius * 0.86;
    final needleBaseLen = radius * 0.12;

    // base shadow
    final shadow = Paint()
      ..color = Colors.black12
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      _polar(center, needleLen, angle),
      shadow,
    );

    final needlePaint = Paint()
      ..color = active ? const Color(0xFF263238) : const Color(0xFF9E9E9E)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, _polar(center, needleLen, angle), needlePaint);

    // small counter-weight behind center
    canvas.drawLine(
      center,
      _polar(center, needleBaseLen, angle + math.pi),
      needlePaint,
    );

    // Center knob
    final knob = Paint()..color = const Color(0xFF263238);
    canvas.drawCircle(center, trackWidth * 0.45, knob);

    // Value label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${clamped.toStringAsFixed(0)} dB',
        style: const TextStyle(
          color: Color(0xFF073C59),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final tpOffset = Offset(center.dx - textPainter.width / 2, center.dy - radius * 0.65);
    textPainter.paint(canvas, tpOffset);
  }

  Offset _polar(Offset center, double r, double angle) {
    return Offset(
      center.dx + r * math.cos(angle),
      center.dy + r * math.sin(angle),
    );
  }

  @override
  bool shouldRepaint(covariant _SoundGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.active != active;
  }
}

