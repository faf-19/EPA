import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class ReportItem {
  final String? id;
  final String title;
  final String? reportType;
  final String status;
  final String description;
  final String date;

  ReportItem({
    this.id,
    required this.title,
    this.reportType,
    required this.status,
    required this.description,
    required this.date,
  });

  // Factory constructor to create ReportItem from API response
  factory ReportItem.fromJson(Map<String, dynamic> json) {
    // Parse date - handle different date formats
    String dateStr = '';
    if (json['created_at'] != null) {
      try {
        final date = DateTime.parse(json['created_at'].toString());
        dateStr = '${_getMonthName(date.month)} ${date.day}, ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        dateStr = json['created_at'].toString();
      }
    } else if (json['date'] != null) {
      dateStr = json['date'].toString();
    } else {
      dateStr = 'N/A';
    }

    // Map status - handle different status formats
    String status = 'Pending';
    if (json['status'] != null) {
      final statusStr = json['status'].toString().toLowerCase();
      if (statusStr.contains('pending')) {
        status = 'Pending';
      } else if (statusStr.contains('progress') || statusStr.contains('investigation')) {
        status = 'In Progress';
      } else if (statusStr.contains('completed') || statusStr.contains('closed')) {
        status = 'Completed';
      } else if (statusStr.contains('rejected')) {
        status = 'Rejected';
      } else {
        status = json['status'].toString();
      }
    }

    return ReportItem(
      id: json['complaint_id']?.toString() ?? 
          json['id']?.toString() ?? 
          json['complaintId']?.toString(),
      title: json['title']?.toString() ?? 
             json['pollution_category']?.toString() ?? 
             json['category']?.toString() ?? 
             'Report',
      reportType: json['pollution_category']?.toString() ?? 
                  json['category']?.toString() ?? 
                  json['report_type']?.toString() ?? 
                  'Environmental',
      status: status,
      description: json['detail']?.toString() ?? 
                   json['description']?.toString() ?? 
                   json['details']?.toString() ?? 
                   'No description available',
      date: dateStr,
    );
  }

  static String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class StatusController extends GetxController {
  // simple counter left for possible future use
  final count = 0.obs;

  /// Current selected filter (All, Pending, In Progress, Completed, Rejected)
  var selectedFilter = 'All'.obs;

  /// All reports (fetched from API)
  final RxList<ReportItem> allReports = <ReportItem>[].obs;

  /// Filtered reports exposed to the view
  final RxList<ReportItem> filteredReports = <ReportItem>[].obs;

  /// Loading state
  var isLoading = false.obs;

  /// Error message
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchComplaints();
  }

  /// Fetch complaints from API using user ID
  Future<void> fetchComplaints() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final storage = Get.find<GetStorage>();
      final userId = storage.read('userId') ?? storage.read('user_id');
      
      if (userId == null) {
        errorMessage.value = 'User not logged in. Please login to view your complaints.';
        isLoading.value = false;
        return;
      }

      final httpClient = Get.find<DioClient>().dio;
      final token = storage.read('auth_token');

      // Fetch complaint using user ID as complaint ID
      final response = await httpClient.get(
        ApiConstants.complaintByIdEndpoint(userId),
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> complaintsList = [];
        
        if (data is List) {
          complaintsList = data;
        } else if (data is Map) {
          // Check for nested data first
          if (data['data'] is List) {
            complaintsList = data['data'];
          } else if (data['complaints'] is List) {
            complaintsList = data['complaints'];
          } else {
            // Single complaint object
            complaintsList = [data];
          }
        }

        // Convert to ReportItem list
        allReports.assignAll(
          complaintsList.map((json) => ReportItem.fromJson(
            json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json)
          )).toList(),
        );

        // Initialize filtered list
        applyFilter();
      } else {
        errorMessage.value = 'Failed to fetch complaints. Please try again.';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No complaints found - this is okay, just show empty list
        allReports.clear();
        applyFilter();
      } else {
        errorMessage.value = e.response?.data?['message']?.toString() ?? 
                            e.message ?? 
                            'Failed to fetch complaints. Please check your connection.';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh complaints
  Future<void> refreshComplaints() async {
    await fetchComplaints();
  }

  void increment() => count.value++;

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  void applyFilter() {
    final f = selectedFilter.value;
    if (f == 'All') {
      filteredReports.assignAll(allReports);
    } else {
      filteredReports.assignAll(allReports.where((r) => r.status == f));
    }
  }
}
