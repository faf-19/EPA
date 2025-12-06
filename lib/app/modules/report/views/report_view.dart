import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:eprs/core/enums/report_type_enum.dart';
import 'package:eprs/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/modules/report/views/report_otp_view.dart';

import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  final String reportType;

  const ReportView({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    // Area data used by the dropdown in the form. Declared here so
    // they're regular statements (not placed inside the widget list).
    final areas = [
      'Select land use type',
      'Environmental Pollution',
      'Urban Waste',
      'Environmental Compliance',
      'Chemical & Hazardous Waste',
    ];

    // Separate notifier for the area dropdown
    final areasNotifier = ValueNotifier<String?>(areas.first);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Report Issue',
        subtitle: 'Help improve your community',
        showBack: true,
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
                          switch (reportType) {
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

              // const SizedBox(height: 12),

              if (reportType == ReportTypeEnum.sound.name)
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
                        const Text(
                          'Area',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder<String?>(
                          valueListenable: areasNotifier,
                          builder: (context, value, _) {
                            return DropdownButtonFormField<String>(
                              initialValue: value == areas.first ? null : value,
                              items: areas
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c == areas.first ? null : c,
                                      child: Text(
                                        c,
                                        style: TextStyle(
                                          color: c == areas.first
                                              ? Colors.grey.shade500
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                // persist locally — replace with controller logic if desired:
                                areasNotifier.value = v ?? areas.first;
                                // Example wiring if your controller exposes a setter:
                                // controller.setReportCategory?.call(v);
                                // or if controller.selectedReportType exists:
                                // controller.selectedReportType.value = v ?? '';
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 0.2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFD4D4D4),
                                    width: 0.4, // 👉 thinner
                                  ),
                                ),

                                // 🔹 Focused border (also missing)
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF1E9B47), // green
                                    width:
                                        0.8, // slightly thicker for visibility
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: areas.first,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 18),

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
                      // Show recording UI if recording, otherwise show tiles
                      Obx(() {
                        if (controller.isRecording.value || controller.isPaused.value) {
                          return _buildRecordingUI(context);
                        }
                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          // narrower aspect so tile height grows slightly to fit icon + label
                          // lower ratio => taller tiles
                          childAspectRatio: 1.9,
                          children: [
                            _evidenceTile(
                              context,
                              Icons.camera_alt_outlined,
                              'Photo',
                            ),
                            reportType != ReportTypeEnum.sound.name
                                ? _evidenceTile(
                                    context,
                                    Icons.videocam_outlined,
                                    'Take Video',
                                  )
                                : _evidenceTile(
                                    context,
                                    Icons.keyboard_voice_outlined,
                                    'Voice Note',
                                    isVoiceNote: true,
                                  ),
                          ],
                        );
                      }),
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
                                  final file = imgs[i];
                                  final isAudio = file.path.toLowerCase().endsWith('.m4a') ||
                                      file.path.toLowerCase().endsWith('.mp3') ||
                                      file.path.toLowerCase().endsWith('.wav') ||
                                      file.path.toLowerCase().endsWith('.aac');
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
                                              : kIsWeb
                                                  ? Image.network(
                                                      file.path,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) =>
                                                          const Icon(Icons.image),
                                                    )
                                                  : Image.file(
                                                      file,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) =>
                                                          const Icon(Icons.image),
                                                    ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => controller.pickedImages
                                              .removeAt(i),
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

              const SizedBox(height: 18),

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
                      // Region/Zone/Woreda dropdowns; disabled when auto-detect is ON
                      const SizedBox(height: 12),

                      // Dropdowns are always enabled for better UX
                      Column(
                        children: [
                          // Region dropdown (populated from API)
                          Obx(() {
                            final items = controller.regions;
                            final names = ['Select Region'] + items.map((e) => e['name']!).toList();
                            // Ensure selectedRegion is set to placeholder if not in list
                            if (items.isNotEmpty && !names.contains(controller.selectedRegion.value)) {
                              controller.selectedRegion.value = 'Select Region';
                            }
                            return _buildDropdown(
                              'Region',
                              names,
                              value: controller.selectedRegion.value,
                              enabled: true, // Always enabled so users can see and select options
                              onChanged: (v) {
                                final selected = v ?? 'Select Region';
                                controller.selectedRegion.value = selected;
                                // find id and load zones (always fetch to populate dropdowns)
                                final id = controller.findIdByName(controller.regions, selected);
                                if (id != null) {
                                  controller.fetchZonesForRegion(id);
                                } else {
                                  controller.zones.clear();
                                  controller.woredas.clear();
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 8),
                          // Zone dropdown (depends on selected region)
                          Obx(() {
                            final items = controller.zones;
                            final names = ['Select Zone'] + items.map((e) => e['name']!).toList();
                            // Ensure selectedZone is set to placeholder if not in list
                            if (items.isNotEmpty && !names.contains(controller.selectedZone.value)) {
                              controller.selectedZone.value = 'Select Zone';
                            }
                            return _buildDropdown(
                              'Zone',
                              names,
                              value: controller.selectedZone.value,
                              enabled: true, // Always enabled so users can see and select options
                              onChanged: (v) {
                                final selected = v ?? 'Select Zone';
                                controller.selectedZone.value = selected;
                                // find id and load woredas (always fetch to populate dropdowns)
                                final id = controller.findIdByName(controller.zones, selected);
                                if (id != null) {
                                  controller.fetchWoredasForZone(id);
                                } else {
                                  controller.woredas.clear();
                                }
                              },
                            );
                          }),
                          const SizedBox(height: 8),
                          // Woreda dropdown (depends on selected zone)
                          Obx(() {
                            final items = controller.woredas;
                            final names = ['Select Woreda'] + items.map((e) => e['name']!).toList();
                            // Ensure selectedWoreda is set to placeholder if not in list
                            if (items.isNotEmpty && !names.contains(controller.selectedWoreda.value)) {
                              controller.selectedWoreda.value = 'Select Woreda';
                            }
                            return _buildDropdown(
                              'Woreda',
                              names,
                              value: controller.selectedWoreda.value,
                              enabled: true, // Always enabled so users can see and select options
                              onChanged: (v) => controller.selectedWoreda.value = v ?? 'Select Woreda',
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

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
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Describe the issue in detail. What exactly is the Problem? When did you notice it?',
                          hintStyle: TextStyle(fontSize: 13),
                          fillColor: const Color(0xFFF3F7F4),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFFD4D4D4)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFFD4D4D4),
                              width: 0.4, // 👉 thinner
                            ),
                          ),

                          // 🔹 Focused border (also missing)
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFF1E9B47), // green
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
              Card(
                color: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Phone Number',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Place the phone field and the ON/OFF toggle side-by-side
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: 'Enter Your Phone Number',
                                hintStyle: TextStyle(fontSize: 13),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFD4D4D4),
                                    width: 0.5,
                                  ),
                                ),

                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFFD4D4D4),
                                    width: 0.4,
                                  ),
                                ),

                                // Focused border
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xFF1E9B47), // green
                                    width: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Keep the toggle compact and vertically centered
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Bind the phone toggle to a separate observable so it
                              // doesn't trigger location auto-detect when toggled.
                              _onOffToggle(
                                bound: controller.phoneOptIn,
                                isPhoneNumber: true,
                                onChanged: (v) =>
                                    controller.togglePhoneOptIn(v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

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
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Text(label),
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
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Text(label),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Terms checkbox
              Row(
                children: [
                  Checkbox(value: false, onChanged: (v) {}),
                  const Expanded(
                    child: Text(
                      'I Agree To The Terms And Conditions',
                      style: TextStyle(
                        color: AppColors.primary
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Send button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReportOtpView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SEND',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _evidenceTile(BuildContext ctx, IconData icon, String label, {bool isVoiceNote = false}) {
    return InkWell(
      onTap: () async {
        if (isVoiceNote) {
          // Start recording immediately when voice note button is pressed
          await controller.startRecording();
          return;
        }

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
    return Obx(() {
      final duration = controller.recordingDuration.value;
      final isPaused = controller.isPaused.value;
      
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4D4D4), width: 0.4),
        ),
        child: Column(
          children: [
            // Waveform visualization
            SizedBox(
              height: 80,
              child: _buildWaveform(),
            ),
            const SizedBox(height: 16),
            // Frequency and Duration display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Frequency 2db',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
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
            // Three buttons: Stop, Cancel, Pause/Resume
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Stop button
                _buildRecordingButton(
                  icon: Icons.stop,
                  label: 'Stop',
                  color: Colors.red,
                  onPressed: () => controller.stopRecording(),
                ),
                // Cancel button
                _buildRecordingButton(
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                  color: Colors.grey,
                  onPressed: () => controller.cancelRecording(),
                ),
                // Pause/Resume button
                _buildRecordingButton(
                  icon: isPaused ? Icons.play_arrow : Icons.pause,
                  label: isPaused ? 'Resume' : 'Pause',
                  color: AppColors.primary,
                  onPressed: () {
                    if (isPaused) {
                      controller.resumeRecording();
                    } else {
                      controller.pauseRecording();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWaveform() {
    return Obx(() {
      final isPaused = controller.isPaused.value;
      final duration = controller.recordingDuration.value;
      return CustomPaint(
        painter: WaveformPainter(
          isPaused: isPaused,
          seed: duration.inSeconds,
        ),
        child: Container(),
      );
    });
  }

  Widget _buildRecordingButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
              child: Icon(
                icon,
                color: Colors.white,
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
          value: currentValue,
          items: items.isEmpty
              ? null
              : items
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ))
                  .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            hintText: items.isNotEmpty ? items.first : label,
          ),
          // Add this to ensure dropdown shows items even when disabled
          isExpanded: true,
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
        onTap: () {
          final newVal = !isOn;
          if (onChanged != null) {
            onChanged(newVal);
          } else if (bound != null) {
            bound.value = newVal;
          } else {
            controller.toggleAutoDetect(newVal);
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
                          isOn ? 'SHOW' : 'HIDE',
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

// Waveform painter for audio recording visualization
class WaveformPainter extends CustomPainter {
  final bool isPaused;
  final int seed;

  WaveformPainter({required this.isPaused, this.seed = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isPaused ? Colors.grey.shade400 : const Color(0xFF63557F)
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final centerY = size.height / 2;
    final barWidth = 3.0;
    final barSpacing = 4.0;
    final maxBarHeight = size.height * 0.8;
    
    // Generate waveform bars with animation
    final barCount = ((size.width - barWidth) / (barWidth + barSpacing)).floor();
    
    for (int i = 0; i < barCount; i++) {
      // Create a pseudo-random pattern that looks like a waveform
      // Use seed to make it change over time
      final barSeed = (seed + i * 7) % 100;
      final height = (maxBarHeight * (0.3 + (barSeed / 100) * 0.7));
      
      final x = i * (barWidth + barSpacing) + barWidth / 2;
      final topY = centerY - height / 2;
      final bottomY = centerY + height / 2;
      
      canvas.drawLine(
        Offset(x, topY),
        Offset(x, bottomY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.isPaused != isPaused || oldDelegate.seed != seed;
  }
}
