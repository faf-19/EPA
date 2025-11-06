import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';
import 'package:eprs/app/routes/app_pages.dart';
import 'package:eprs/app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  final String reportType;

  const ReportView({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Report Issue',
        subtitle: 'Help improve your community',
        showBack: true,
      ),
      backgroundColor: const Color(0xFFF6F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Evidence Card
              Card(
                color: const Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
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
                              color: Color(0xFF6B46FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
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
                            Icons.camera_alt_outlined,
                            'Take Photo',
                          ),
                          _evidenceTile(
                            Icons.videocam_outlined,
                            'Record Video',
                          ),
                          _evidenceTile(
                            Icons.photo_library_outlined,
                            'From Gallery',
                          ),
                          _evidenceTile(Icons.mic_none_outlined, 'Voice Note'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF7F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '1 File(s) Uploaded',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
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
                elevation: 4,
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

                      // reactive: hide dropdowns when auto-detect is ON
                      Obx(() {
                        final autoOn = controller.autoDetectLocation.value;
                        if (autoOn) return const SizedBox.shrink();
                        return Column(
                          children: [
                            _buildDropdown(
                              'Region',
                              ['Select Region', 'Addis Ababa', 'Oromia'],
                              value: controller.selectedRegion.value,
                              enabled: true,
                              onChanged: (v) =>
                                  controller.selectedRegion.value =
                                      v ?? 'Select Region',
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              'Zone',
                              ['Select Zone', 'Zone 1', 'Zone 2'],
                              value: controller.selectedZone.value,
                              enabled: true,
                              onChanged: (v) => controller.selectedZone.value =
                                  v ?? 'Select Zone',
                            ),
                            const SizedBox(height: 8),
                            _buildDropdown(
                              'Woreda',
                              ['Select Woreda', 'Woreda 1', 'Woreda 2'],
                              value: controller.selectedWoreda.value,
                              enabled: true,
                              onChanged: (v) =>
                                  controller.selectedWoreda.value =
                                      v ?? 'Select Woreda',
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Description Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText:
                              'Describe the issue in detail. What exactly is the Problem? When did you notice it?',
                          fillColor: const Color(0xFFF3F7F4),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
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
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter Your Phone Number',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Time & Date Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time and Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: const Text('Select Date'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: const Text('Select Time'),
                            ),
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
                      style: TextStyle(color: Colors.blue),
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
                    Get.toNamed(Routes.Report_Otp);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1EA04A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SEND',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 80), // give space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget _evidenceTile(IconData icon, String label) {
    return InkWell(
      onTap: () {},
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
                    Icon(icon, size: 28, color: const Color(0xFF6B46FF)),
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

  Widget _buildDropdown(
    String label,
    List<String> items, {
    required String value,
    required bool enabled,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
          ),
        ),
      ],
    );
  }

  /// Custom rounded toggle with internal ON/OFF label to match the design.
  Widget _onOffToggle() {
    return Obx(() {
      final isOn = controller.autoDetectLocation.value;
      return GestureDetector(
        onTap: () => controller.toggleAutoDetect(!isOn),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 92,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isOn ? Colors.green : Colors.grey.shade300,
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
                  child: Text(
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
