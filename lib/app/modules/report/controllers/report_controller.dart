import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ReportController extends GetxController {
  // Location & form state for the report view
  final count = 0.obs;

  /// When true, the app should attempt to auto-detect the user's location.
  final autoDetectLocation = true.obs;
  
  /// Human-readable detected address (or placeholder) shown when auto-detect is enabled.
  final detectedAddress = 'Tap Search Location\nAddis Ababa | N.L | W-1'.obs;

  // Manual selection values (used when autoDetectLocation is false)
  final selectedRegion = 'Select Region'.obs;
  final selectedZone = 'Select Zone'.obs;
  final selectedWoreda = 'Select Woreda'.obs;
  final pickedImages = <File>[].obs;


  /// Whether a location fetch is in progress.
  final isDetecting = false.obs;

  /// Last error message (if any).
  final detectionError = RxnString();

  /// Last detected Position.
  final detectedPosition = Rxn<Position>();

  /// Whether the phone-field toggle is ON (separate from location auto-detect).
  /// This prevents the phone toggle from triggering the location toggle.
  final phoneOptIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // If auto-detect is enabled by default, start detection asynchronously.
    if (autoDetectLocation.value) {
      // do not await here (onInit must remain synchronous) — detectLocation will
      // perform async permission requests and fetching internally and update
      // reactive fields when ready.
      detectLocation();
    }
  }



  void increment() => count.value++;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );

    if (image != null) {
      pickedImages.add(File(image.path));
    }
  }

  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );

    if (image != null) {
      pickedImages.add(File(image.path));
    }
  }
  /// Toggle automatic detection. When turned on we attempt to detect location.
  void toggleAutoDetect(bool value) {
    autoDetectLocation.value = value;
    detectionError.value = null;
    if (value) {
      detectLocation();
    }
  }

  /// Toggle the phone-field option independently from location detection.
  void togglePhoneOptIn(bool value) {
    phoneOptIn.value = value;
  }

  /// Orchestrates permission request, position fetch and reverse-geocoding.
  /// Updates [detectedAddress], [detectedPosition], [isDetecting] and
  /// [detectionError] appropriately.
  Future<void> detectLocation({int timeoutSeconds = 12}) async {
    detectionError.value = null;
    isDetecting.value = true;
    try {
      final ok = await _ensurePermission();
      if (!ok) {
        // Permission denied — leave the placeholder and show error.
        detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
        isDetecting.value = false;
        return;
      }

      // Fetch current position with a reasonable timeout.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(Duration(seconds: timeoutSeconds));

      detectedPosition.value = position;

      // Reverse geocode to a human-readable placemark. If that fails, fall back
      // to lat/lng string.
      try {
        // On web reverse-geocoding via the geocoding package can be unreliable
        // (permissions, browser limitations, or upstream API differences). Use
        // a safe fallback: skip reverse lookup on web and show coordinates.
        if (kIsWeb) {
          detectedAddress.value =
              'Lat ${position.latitude.toStringAsFixed(5)}, Lng ${position.longitude.toStringAsFixed(5)}';
        } else {
          final places = await placemarkFromCoordinates(position.latitude, position.longitude);
          // Defensive: some platforms/implementations may return an empty list.
          if (places.isNotEmpty) {
            final p = places.first;
            final parts = <String>[];
            final name = p.name ?? '';
            final subLocality = p.subLocality ?? '';
            final locality = p.locality ?? '';
            final admin = p.administrativeArea ?? '';
            final country = p.country ?? '';
            if (name.isNotEmpty) parts.add(name);
            if (subLocality.isNotEmpty) parts.add(subLocality);
            if (locality.isNotEmpty) parts.add(locality);
            if (admin.isNotEmpty) parts.add(admin);
            if (country.isNotEmpty) parts.add(country);
            detectedAddress.value = parts.join(', ');
          } else {
            // No usable placemark — fall back to latitude/longitude string.
            detectedAddress.value =
                'Lat ${position.latitude.toStringAsFixed(5)}, Lng ${position.longitude.toStringAsFixed(5)}';
          }
        }
      } catch (e, st) {
        // Reverse geocoding failed — log and fall back to coordinates.
        detectionError.value = 'Unable to resolve address';
        detectedAddress.value =
            'Lat ${position.latitude.toStringAsFixed(5)}, Lng ${position.longitude.toStringAsFixed(5)}';
        // keep a developer-visible log
        print('reverseGeocode error: $e\n$st');
      }
    } on TimeoutException catch (e, st) {
      detectionError.value = 'Location request timed out';
      detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
      print('detectLocation timeout: $e\n$st');
    } catch (e, st) {
      detectionError.value = 'Could not detect location';
      detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
      print('detectLocation error: $e\n$st');
    } finally {
      isDetecting.value = false;
    }
  }

  /// Ensure location permission is granted. Returns true if permission is
  /// available, false otherwise. Sets [detectionError] on denial.
  Future<bool> _ensurePermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        detectionError.value = 'Location services are disabled.';
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        detectionError.value = 'Location permission denied.';
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        detectionError.value = 'Location permission permanently denied. Enable it from settings.';
        return false;
      }
      return true;
    } catch (e, st) {
      detectionError.value = 'Permission check failed';
      print('permission error: $e\n$st');
      return false;
    }
  }
}

