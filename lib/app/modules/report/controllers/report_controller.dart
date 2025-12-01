import 'dart:async';
import 'dart:io';

import 'package:eprs/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ReportController extends GetxController {
  // State
  final count = 0.obs;

  final autoDetectLocation = true.obs;
  final detectedAddress = 'Tap Search Location\nAddis Ababa | N.L | W-1'.obs;

  final selectedRegion = 'Select Region'.obs;
  final selectedZone = 'Select Zone'.obs;
  final selectedWoreda = 'Select Woreda'.obs;

  final pickedImages = <File>[].obs;

  final isDetecting = false.obs;
  final detectionError = RxnString();
  final detectedPosition = Rxn<Position>();

  final phoneOptIn = false.obs;

  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (autoDetectLocation.value) {
      detectLocation();
    }
  }

  // ----------------------------
  // DATE PICKER
  // ----------------------------
  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final first = DateTime(now.year - 5);
    final last = DateTime(now.year, now.month, now.day);

    DateTime initial = selectedDate.value ?? now;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFFF6F6FA)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) selectedDate.value = picked;
  }

  // ----------------------------
  // TIME PICKER (CUSTOM AM/PM)
  // ----------------------------
  Future<void> pickTime(BuildContext context) async {
    final initial = selectedTime.value ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),

            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.onPrimary,
              dialBackgroundColor: Colors.white,

              // Custom AM/PM background (use plain Color for compatibility)
              dayPeriodColor: AppColors.primary.withOpacity(0.12),

              // Custom AM/PM text color
              dayPeriodTextColor: AppColors.primary,

              dayPeriodTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),

              // Hour/minute text color
              hourMinuteTextColor: AppColors.onPrimary,
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),

          child: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) selectedTime.value = picked;
  }

  // ----------------------------
  // IMAGE PICKING
  // ----------------------------
  Future<void> pickFromCamera() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (img != null) pickedImages.add(File(img.path));
  }

  Future<void> pickFromGallery() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (img != null) pickedImages.add(File(img.path));
  }

  // ----------------------------
  // LOCATION LOGIC
  // ----------------------------
  void toggleAutoDetect(bool v) {
    autoDetectLocation.value = v;
    detectionError.value = null;
    if (v) detectLocation();
  }

  void togglePhoneOptIn(bool v) {
    phoneOptIn.value = v;
  }

  Future<void> detectLocation({int timeoutSeconds = 12}) async {
    detectionError.value = null;
    isDetecting.value = true;

    try {
      final allowed = await _ensurePermission();
      if (!allowed) {
        detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
        isDetecting.value = false;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(Duration(seconds: timeoutSeconds));

      detectedPosition.value = pos;

      // Reverse geocode
      try {
        if (kIsWeb) {
          detectedAddress.value =
              'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
        } else {
          final places =
              await placemarkFromCoordinates(pos.latitude, pos.longitude);

          if (places.isEmpty) {
            detectedAddress.value =
                'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
          } else {
            final p = places.first;
            final parts = [
              p.name,
              p.subLocality,
              p.locality,
              p.administrativeArea,
              p.country
            ].where((e) => e != null && e.isNotEmpty).toList();

            detectedAddress.value = parts.join(', ');
          }
        }
      } catch (_) {
        detectionError.value = 'Unable to resolve address';
        detectedAddress.value =
            'Lat ${pos.latitude.toStringAsFixed(5)}, Lng ${pos.longitude.toStringAsFixed(5)}';
      }
    } catch (_) {
      detectionError.value = 'Could not detect location';
      detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
    } finally {
      isDetecting.value = false;
    }
  }

  Future<bool> _ensurePermission() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        detectionError.value = 'Location services are disabled.';
        return false;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        detectionError.value = 'Location permission denied.';
        return false;
      }

      if (perm == LocationPermission.deniedForever) {
        detectionError.value =
            'Location permanently denied. Enable it in settings.';
        return false;
      }

      return true;
    } catch (_) {
      detectionError.value = 'Permission check failed.';
      return false;
    }
  }

  void increment() => count.value++;
}
