import 'dart:async';

import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

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

  /// Whether a location fetch is in progress.
  final isDetecting = false.obs;

  /// Last error message (if any).
  final detectionError = RxnString();

  /// Last detected Position.
  final detectedPosition = Rxn<Position>();

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

  /// Toggle automatic detection. When turned on we attempt to detect location.
  void toggleAutoDetect(bool value) {
    autoDetectLocation.value = value;
    detectionError.value = null;
    if (value) {
      detectLocation();
    }
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
        final places = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (places.isNotEmpty) {
          final p = places.first;
          final parts = <String>[];
          if ((p.name ?? '').isNotEmpty) parts.add(p.name!);
          if ((p.subLocality ?? '').isNotEmpty) parts.add(p.subLocality!);
          if ((p.locality ?? '').isNotEmpty) parts.add(p.locality!);
          if ((p.administrativeArea ?? '').isNotEmpty) parts.add(p.administrativeArea!);
          if ((p.country ?? '').isNotEmpty) parts.add(p.country!);
          detectedAddress.value = parts.join(', ');
        } else {
          detectedAddress.value = 'Lat ${position.latitude.toStringAsFixed(5)}, Lng ${position.longitude.toStringAsFixed(5)}';
        }
      } catch (e, st) {
        // Reverse geocoding failed — log and fall back to coordinates.
        detectionError.value = 'Unable to resolve address';
        detectedAddress.value = 'Lat ${position.latitude.toStringAsFixed(5)}, Lng ${position.longitude.toStringAsFixed(5)}';
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

