import 'dart:async';
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
import 'package:dio/dio.dart' as dio;
import 'package:eprs/core/network/dio_client.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:eprs/app/routes/app_pages.dart';
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

  // Store XFile for web compatibility
  // Renamed from pickedImages to force new instance (fixes hot reload type issues)
  final pickedImagesX = <XFile>[].obs;
  
  // Getter for backward compatibility
  RxList<XFile> get pickedImages => pickedImagesX;
  
  // Helper to add a file
  void addPickedImage(XFile file) {
    pickedImagesX.add(file);
  }
  
  // Helper to remove a file
  void removePickedImageAt(int index) {
    if (index >= 0 && index < pickedImagesX.length) {
      pickedImagesX.removeAt(index);
    }
  }

  final isDetecting = false.obs;
  final detectionError = RxnString();
  final detectedPosition = Rxn<Position>();

  final phoneOptIn = false.obs;

  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();

  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final descriptionController = TextEditingController();
  final phoneController = TextEditingController();
  final termsAccepted = false.obs;
  
  // Report type and pollution category ID
  String reportType = '';
  String? pollutionCategoryId; // Will be set from route arguments
  
  // Loading state for submission
  final isSubmitting = false.obs;

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
    // Reset form to ensure clean state when entering the page
    _resetForm();
    
    // Get report type and pollution category ID from arguments
    final args = Get.arguments;
    if (args is String) {
      reportType = args;
    } else if (args is Map) {
      if (args['reportType'] is String) {
        reportType = args['reportType'];
      }
      if (args['pollutionCategoryId'] is String) {
        pollutionCategoryId = args['pollutionCategoryId'];
        print('Received pollution category ID from route: $pollutionCategoryId');
      } else {
        print('No pollution category ID in route arguments. Available keys: ${args.keys.toList()}');
      }
    }
    
    if (autoDetectLocation.value) {
      detectLocation();
    }
    // Fetch regions from API
    fetchRegions();
  }

  // Reset form to initial state
  void _resetForm() {
    // Clear text fields
    descriptionController.clear();
    phoneController.clear();
    
    // Clear selected values
    selectedRegion.value = 'Select Region';
    selectedZone.value = 'Select Zone';
    selectedWoreda.value = 'Select Woreda';
    
    // Clear location data
    regions.clear();
    zones.clear();
    woredas.clear();
    
    // Clear picked images
    pickedImagesX.clear();
    
    // Clear date and time
    selectedDate.value = null;
    selectedTime.value = null;
    
    // Clear location detection
    detectedPosition.value = null;
    detectedAddress.value = 'Tap Search Location\nAddis Ababa | N.L | W-1';
    autoDetectLocation.value = false;
    
    // Clear terms acceptance
    termsAccepted.value = false;
    phoneOptIn.value = false;
    
    // Clear audio recording
    audioFilePath.value = null;
    isRecording.value = false;
    isPaused.value = false;
    recordingDuration.value = Duration.zero;
    
    // Reset pollution category ID
    pollutionCategoryId = null;
    
    print('Form reset completed');
  }
  
  @override
  void onClose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    super.onClose();
  }
  
  // ----------------------------
  // LOCAL DATA (temporary - replace with API later)
  // ----------------------------
  void loadLocalRegions() {
    regions.clear();
    regions.addAll([
      {'id': 'bc7e6719-cfe4-4464-b237-2b0df88dd734', 'name': 'Oromia'},
      {'id': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'name': 'Amhara'},
      {'id': 'f1e2d3c4-b5a6-9876-5432-10fedcba9876', 'name': 'Tigray'},
      {'id': '12345678-1234-1234-1234-123456789abc', 'name': 'SNNPR'},
      {'id': 'abcdef12-3456-7890-abcd-ef1234567890', 'name': 'Addis Ababa'},
    ]);
  }
  
  void loadLocalZones(String regionId) {
    zones.clear();
    selectedZone.value = 'Select Zone';
    woredas.clear();
    selectedWoreda.value = 'Select Woreda';
    
    // Sample zones for Oromia
    if (regionId == 'bc7e6719-cfe4-4464-b237-2b0df88dd734') {
      zones.addAll([
        {'id': '11111111-1111-1111-1111-111111111111', 'name': 'East Shewa'},
        {'id': '22222222-2222-2222-2222-222222222222', 'name': 'West Shewa'},
        {'id': '33333333-3333-3333-3333-333333333333', 'name': 'North Shewa'},
      ]);
    } else {
      // Default zones for other regions
      zones.addAll([
        {'id': '11111111-1111-1111-1111-111111111111', 'name': 'Zone 1'},
        {'id': '22222222-2222-2222-2222-222222222222', 'name': 'Zone 2'},
        {'id': '33333333-3333-3333-3333-333333333333', 'name': 'Zone 3'},
      ]);
    }
  }
  
  void loadLocalWoredas(String zoneId) {
    woredas.clear();
    selectedWoreda.value = 'Select Woreda';
    
    // Sample woredas with valid UUIDs
    woredas.addAll([
      {'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'name': 'Woreda 1'},
      {'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'name': 'Woreda 2'},
      {'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'name': 'Woreda 3'},
    ]);
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
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        ApiConstants.regionsEndpoint,
        options: dio.Options(headers: {
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
    isLoadingZones.value = true;
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        '${ApiConstants.zonesByRegionEndpoint}/$regionId',
        options: dio.Options(headers: {
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
    isLoadingWoredas.value = true;
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        '${ApiConstants.woredasByLocationEndpoint}/$zoneId',
        options: dio.Options(headers: {
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
  // IMAGE/VIDEO PICKING
  // ----------------------------
  Future<void> pickFromCamera() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (img != null) addPickedImage(img);
  }

  Future<void> pickFromGallery() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (img != null) addPickedImage(img);
  }
  
  Future<void> pickVideoFromCamera() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) addPickedImage(video);
  }
  
  Future<void> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (video != null) addPickedImage(video);
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
      String filePath;
      if (kIsWeb) {
        // On web, use a temporary path
        filePath = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        filePath = path.join(directory.path, fileName);
      }

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
          // Create XFile from path (works on both web and mobile)
          final xFile = XFile(audioFilePath.value!);
          addPickedImage(xFile);
          Get.snackbar(
            'Recording Saved',
            'Voice note has been saved',
            snackPosition: SnackPosition.BOTTOM,
          );
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
        
        // Delete the file if it exists (only on mobile)
        if (audioFilePath.value != null && !kIsWeb) {
          try {
            // On mobile, we can delete the file
            // Note: File operations are handled by the record package
            // The file will be cleaned up automatically
          } catch (_) {
            // Ignore errors
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
  
  // ----------------------------
  // FORM SUBMISSION
  // ----------------------------
  // Fetch pollution category ID from API
  Future<String?> _fetchPollutionCategoryId(String reportType) async {
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      final res = await httpClient.get(
        ApiConstants.pollutionCategoriesEndpoint,
        options: dio.Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      
      final data = res.data;
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        if (data['data'] is List) {
          items = data['data'];
        } else if (data['categories'] is List) {
          items = data['categories'];
        }
      }
      
      // Try to find matching category
      final normalizedType = reportType.toLowerCase().trim();
      for (var item in items) {
        if (item is Map) {
          final id = item['pollution_category_id']?.toString() ?? item['id']?.toString() ?? '';
          final name = (item['pollution_category']?.toString() ?? item['name']?.toString() ?? '').toLowerCase().trim();
          if (id.isNotEmpty && name == normalizedType) {
            print('Found pollution category ID for "$reportType": $id');
            return id;
          }
        }
      }
      
      print('Warning: Could not find pollution category for "$reportType"');
      return null;
    } catch (e) {
      print('Error fetching pollution category: $e');
      return null;
    }
  }
  
  Future<void> submitReport() async {
    // Validation
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide a description', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (pickedImagesX.isEmpty) {
      Get.snackbar('Error', 'Please add at least one photo or video', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (!termsAccepted.value) {
      Get.snackbar('Error', 'Please accept the terms and conditions', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    if (selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar('Error', 'Please select date and time', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    isSubmitting.value = true;
    
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = Get.find<GetStorage>().read('auth_token');
      
      if (token == null) {
        Get.snackbar('Error', 'Please login to submit a report', snackPosition: SnackPosition.BOTTOM);
        isSubmitting.value = false;
        return;
      }
      
      // Get location IDs
      final regionId = findIdByName(regions, selectedRegion.value) ?? '';
      final zoneId = findIdByName(zones, selectedZone.value) ?? '';
      final woredaId = findIdByName(woredas, selectedWoreda.value) ?? '';
      
      // Get location coordinates
      String locationUrl = '';
      if (autoDetectLocation.value && detectedPosition.value != null) {
        final pos = detectedPosition.value!;
        locationUrl = '${pos.latitude},${pos.longitude}';
      }
      
      // Create form data
      final formData = dio.FormData();
      
      // Add text fields
      if (regionId.isNotEmpty) formData.fields.add(MapEntry('region_id', regionId));
      if (zoneId.isNotEmpty) formData.fields.add(MapEntry('zone_id', zoneId));
      if (woredaId.isNotEmpty) formData.fields.add(MapEntry('Woreda_id', woredaId));
      if (locationUrl.isNotEmpty) formData.fields.add(MapEntry('location_url', locationUrl));
      formData.fields.add(MapEntry('detail', descriptionController.text.trim()));
      
      // Add pollution category ID (use from route if available, otherwise fetch from API)
      String? categoryId = pollutionCategoryId;
      if (categoryId == null || categoryId.isEmpty) {
        print('Pollution category ID not in route, fetching from API...');
        categoryId = await _fetchPollutionCategoryId(reportType);
      }
      
      print('Using pollution category ID: $categoryId (from route: ${pollutionCategoryId != null})');
      if (categoryId != null && categoryId.isNotEmpty) {
        formData.fields.add(MapEntry('pollution_category_id', categoryId));
      } else {
        Get.snackbar('Error', 'Could not find pollution category. Please try again.', snackPosition: SnackPosition.BOTTOM);
        isSubmitting.value = false;
        return;
      }
      
      // Add phone if opted in
      if (phoneOptIn.value && phoneController.text.trim().isNotEmpty) {
        formData.fields.add(MapEntry('phone_no', phoneController.text.trim()));
      }
      
      // Add files
      print('Adding ${pickedImagesX.length} files to form data...');
      for (var xFile in pickedImagesX) {
        try {
          final fileName = xFile.name;
          print('Reading file: $fileName');
          final bytes = await xFile.readAsBytes();
          print('File size: ${bytes.length} bytes');
          
          formData.files.add(MapEntry(
            'file',
            dio.MultipartFile.fromBytes(
              bytes,
              filename: fileName,
            ),
          ));
          print('Added file: $fileName');
        } catch (e) {
          print('Error adding file ${xFile.name}: $e');
        }
      }
      print('Total files in form data: ${formData.files.length}');
      
      // Debug: Print form data fields
      print('Form data fields:');
      for (var field in formData.fields) {
        print('  ${field.key}: ${field.value}');
      }
      
      // Submit to API
      print('Submitting to: ${ApiConstants.complaintsEndpoint}');
      print('Total files: ${pickedImagesX.length}');
      
      final response = await httpClient.post(
        ApiConstants.complaintsEndpoint,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            // Don't set Content-Type for multipart/form-data - let Dio set it with boundary
          },
          sendTimeout: const Duration(seconds: 60), // Increase timeout for file uploads
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      
      isSubmitting.value = false;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if user is logged in (has auth token)
        final isLoggedIn = token != null && token.isNotEmpty;
        
        // Extract report ID from response
        String reportId = '';
        try {
          final responseData = response.data;
          print('Response data: $responseData');
          
          if (responseData is Map) {
            // Check if data is nested
            final data = responseData['data'] ?? responseData;
            if (data is Map) {
              reportId = data['report_id']?.toString() ?? 
                        data['complaint_id']?.toString() ?? 
                        data['id']?.toString() ?? '';
            }
            
            // If still not found, check top level
            if (reportId.isEmpty) {
              reportId = responseData['report_id']?.toString() ?? 
                        responseData['complaint_id']?.toString() ?? 
                        responseData['id']?.toString() ?? '';
            }
          }
          
          print('Extracted report ID: $reportId');
        } catch (e) {
          print('Error extracting report ID: $e');
        }
        
        // If no report ID found, generate a temporary one
        if (reportId.isEmpty) {
          reportId = 'REP-${DateTime.now().millisecondsSinceEpoch}';
        }
        
        // Clear form data before navigating
        _resetForm();
        
        if (isLoggedIn) {
          // User is logged in - go directly to success page
          print('User is logged in, navigating to success page with report ID: $reportId');
          Get.offNamed(Routes.Report_Success, arguments: {
            'reportId': reportId,
            'dateTime': DateTime.now(),
          });
        } else {
          // User is a guest - go to OTP page
          print('User is a guest, navigating to OTP page');
          Get.toNamed(Routes.Report_Otp);
        }
      } else {
        Get.snackbar('Error', 'Failed to submit report', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      isSubmitting.value = false;
      print('Error submitting report: $e');
      Get.snackbar('Error', 'Failed to submit report: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
