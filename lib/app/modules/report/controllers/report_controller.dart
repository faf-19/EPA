import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:eprs/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:eprs/core/network/dio_client.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:get_storage/get_storage.dart';

class ReportController extends GetxController {
  // State
  final count = 0.obs;

  final autoDetectLocation = true.obs;
  final detectedAddress = 'Tap Search Location\nAddis Ababa | N.L | W-1'.obs;

  final selectedRegion = 'Select Region'.obs;
  final selectedZone = 'Select Zone'.obs;
  final selectedWoreda = 'Select Woreda'.obs;

  // API-backed location lists (each item: {'id': '...', 'name': '...'})
  final regions = <Map<String, String>>[].obs;
  final zones = <Map<String, String>>[].obs;
  final woredas = <Map<String, String>>[].obs;

  final isLoadingRegions = false.obs;
  final isLoadingZones = false.obs;
  final isLoadingWoredas = false.obs;

  final pickedImages = <File>[].obs;

  final isDetecting = false.obs;
  final detectionError = RxnString();
  final detectedPosition = Rxn<Position>();

  final phoneOptIn = false.obs;

  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();

  final ImagePicker _picker = ImagePicker();

  // Audio recording state
  final AudioRecorder _audioRecorder = AudioRecorder();
  final isRecording = false.obs;
  final isPaused = false.obs;
  final recordingDuration = Duration.zero.obs;
  final audioFilePath = RxnString();
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;
  Duration _pausedDuration = Duration.zero;
  DateTime? _pauseStartTime;

  @override
  void onInit() {
    super.onInit();
    if (autoDetectLocation.value) {
      detectLocation();
    }
    // Load regions from API at init so dropdowns are populated
    fetchRegions();
  }

  @override
  void onClose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.onClose();
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
  // LOCATION API (regions / zones / woredas)
  // ----------------------------
  Future<void> fetchRegions() async {
    isLoadingRegions.value = true;
    try {
      final dio = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await dio.get(
        ApiConstants.regionsEndpoint,
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );

      print('Regions API Response: ${res.data}');
      print('Response Type: ${res.data.runtimeType}');

      final data = res.data;
      List items = [];
      if (data is List) {
        items = data;
        print('Data is a List with ${items.length} items');
      } else if (data is Map) {
        // Try multiple possible keys for the data array
        if (data['data'] is List) {
          items = data['data'];
          print('Data found in data key: ${items.length} items');
        } else if (data['regions'] is List) {
          items = data['regions'];
          print('Data found in regions key: ${items.length} items');
        } else if (data['results'] is List) {
          items = data['results'];
          print('Data found in results key: ${items.length} items');
        } else {
          print('Warning: Could not find data array in response. Available keys: ${data.keys.toList()}');
        }
      }

      regions.clear();
      final mappedRegions = items.map<Map<String, String>>((e) {
        // Prefer explicit keys from the API response (region_id / region_name)
        final id = (e is Map && (e['region_id'] != null))
            ? e['region_id']?.toString() ?? ''
            : (e['id']?.toString() ?? e['regionId']?.toString() ?? '');
        final name = (e is Map && (e['region_name'] != null))
            ? (e['region_name']?.toString() ?? '')
            : (e['name']?.toString() ?? e['title']?.toString() ?? e['region']?.toString() ?? '');
        return {'id': id, 'name': name};
      }).where((m) => m['id']!.isNotEmpty && m['name']!.isNotEmpty).toList();
      
      regions.addAll(mappedRegions);
      // Debug: print mapped regions so we can verify UI data
      print('Mapped regions for UI: ${regions.map((r) => r['name']).toList()}');
      print('Total regions loaded: ${regions.length}');
    } catch (e) {
      print('Error fetching regions: $e');
      Get.snackbar(
        'Error',
        'Failed to load regions: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingRegions.value = false;
    }
  }

  Future<void> fetchZonesForRegion(String regionId) async {
    isLoadingZones.value = true;
    try {
      final dio = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await dio.get(
        '${ApiConstants.zonesByRegionEndpoint}/$regionId',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );

      final data = res.data;
      print('Zones API Response for region $regionId: ${res.data}');
      
      List items = [];
      if (data is List) {
        items = data;
        print('Data is a List with ${items.length} items');
      } else if (data is Map) {
        // Try multiple possible keys for the data array
        if (data['data'] is List) {
          items = data['data'];
          print('Data found in data key: ${items.length} items');
        } else if (data['zones'] is List) {
          items = data['zones'];
          print('Data found in zones key: ${items.length} items');
        } else if (data['results'] is List) {
          items = data['results'];
          print('Data found in results key: ${items.length} items');
        } else {
          print('Warning: Could not find data array in response. Available keys: ${data.keys.toList()}');
        }
      }

      zones.clear();
      // Reset zone selection when loading new zones
      selectedZone.value = 'Select Zone';
      woredas.clear();
      selectedWoreda.value = 'Select Woreda';
      
      final mappedZones = items.map<Map<String, String>>((e) {
        final id = (e is Map && (e['zone_id'] != null))
            ? e['zone_id']?.toString() ?? ''
            : (e['id']?.toString() ?? '');
        final name = (e is Map && (e['zone_name'] != null))
            ? (e['zone_name']?.toString() ?? '')
            : (e['name']?.toString() ?? '');
        return {'id': id, 'name': name};
      }).where((m) => m['id']!.isNotEmpty && m['name']!.isNotEmpty).toList();
      
      zones.addAll(mappedZones);
      print('Mapped zones for UI: ${zones.map((r) => r['name']).toList()}');
      print('Total zones loaded: ${zones.length}');
    } catch (e) {
      print('Error fetching zones: $e');
      Get.snackbar(
        'Error',
        'Failed to load zones: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingZones.value = false;
    }
  }

  Future<void> fetchWoredasForZone(String zoneId) async {
    isLoadingWoredas.value = true;
    try {
      final dio = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await dio.get(
        '${ApiConstants.woredasByLocationEndpoint}/$zoneId',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );

      final data = res.data;
      print('Woredas API Response for zone $zoneId: ${res.data}');
      
      List items = [];
      if (data is List) {
        items = data;
        print('Data is a List with ${items.length} items');
      } else if (data is Map) {
        // Try multiple possible keys for the data array
        if (data['data'] is List) {
          items = data['data'];
          print('Data found in data key: ${items.length} items');
        } else if (data['woredas'] is List) {
          items = data['woredas'];
          print('Data found in woredas key: ${items.length} items');
        } else if (data['results'] is List) {
          items = data['results'];
          print('Data found in results key: ${items.length} items');
        } else {
          print('Warning: Could not find data array in response. Available keys: ${data.keys.toList()}');
        }
      }

      woredas.clear();
      // Reset woreda selection when loading new woredas
      selectedWoreda.value = 'Select Woreda';
      
      final mappedWoredas = items.map<Map<String, String>>((e) {
        final id = (e is Map && (e['woreda_id'] != null))
            ? e['woreda_id']?.toString() ?? ''
            : (e['id']?.toString() ?? '');
        final name = (e is Map && (e['woreda_name'] != null))
            ? (e['woreda_name']?.toString() ?? '')
            : (e['name']?.toString() ?? e['title']?.toString() ?? '');
        return {'id': id, 'name': name};
      }).where((m) => m['id']!.isNotEmpty && m['name']!.isNotEmpty).toList();
      
      woredas.addAll(mappedWoredas);
      print('Mapped woredas for UI: ${woredas.map((r) => r['name']).toList()}');
      print('Total woredas loaded: ${woredas.length}');
    } catch (e) {
      print('Error fetching woredas: $e');
      Get.snackbar(
        'Error',
        'Failed to load woredas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingWoredas.value = false;
    }
  }

  String? findIdByName(List<Map<String, String>> list, String name) {
    try {
      return list.firstWhere((e) => e['name'] == name)['id'];
    } catch (_) {
      return null;
    }
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

  // ----------------------------
  // AUDIO RECORDING
  // ----------------------------
  Future<bool> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    try {
      final hasPermission = await _ensureMicrophonePermission();
      if (!hasPermission) {
        Get.snackbar(
          'Permission Denied',
          'Microphone permission is required to record audio',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get directory for saving audio
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = path.join(directory.path, fileName);

      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        audioFilePath.value = filePath;
        isRecording.value = true;
        isPaused.value = false;
        _pausedDuration = Duration.zero;
        _recordingStartTime = DateTime.now();

        // Start timer to update duration
        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (isRecording.value && !isPaused.value) {
            final now = DateTime.now();
            final elapsed = now.difference(_recordingStartTime!);
            recordingDuration.value = elapsed + _pausedDuration;
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to start recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pauseRecording() async {
    try {
      if (isRecording.value && !isPaused.value) {
        await _audioRecorder.pause();
        isPaused.value = true;
        _pauseStartTime = DateTime.now();
      }
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to pause recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> resumeRecording() async {
    try {
      if (isRecording.value && isPaused.value) {
        await _audioRecorder.resume();
        if (_pauseStartTime != null) {
          final pauseDuration = DateTime.now().difference(_pauseStartTime!);
          _pausedDuration += pauseDuration;
          _pauseStartTime = null;
        }
        isPaused.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to resume recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      if (isRecording.value) {
        final path = await _audioRecorder.stop();
        _recordingTimer?.cancel();
        isRecording.value = false;
        isPaused.value = false;
        
        if (path != null && audioFilePath.value != null) {
          final file = File(audioFilePath.value!);
          if (file.existsSync()) {
            pickedImages.add(file);
            Get.snackbar(
              'Recording Saved',
              'Voice note has been saved',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }

        // Reset state
        recordingDuration.value = Duration.zero;
        audioFilePath.value = null;
        _pausedDuration = Duration.zero;
        _recordingStartTime = null;
        _pauseStartTime = null;
      }
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to stop recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (isRecording.value) {
        await _audioRecorder.stop();
        _recordingTimer?.cancel();
        
        // Delete the file if it exists
        if (audioFilePath.value != null) {
          final file = File(audioFilePath.value!);
          if (file.existsSync()) {
            await file.delete();
          }
        }

        // Reset state
        isRecording.value = false;
        isPaused.value = false;
        recordingDuration.value = Duration.zero;
        audioFilePath.value = null;
        _pausedDuration = Duration.zero;
        _recordingStartTime = null;
        _pauseStartTime = null;
      }
    } catch (e) {
      Get.snackbar(
        'Recording Error',
        'Failed to cancel recording: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
