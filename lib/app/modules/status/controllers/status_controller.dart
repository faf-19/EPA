import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';

class ReportItem {
  final String? id;
  final String? reportId; // Store report_id separately
  final String title;
  final String? reportType;
  final String status;
  final String description;
  final String date;

  ReportItem({
    this.id,
    this.reportId,
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

    // Extract pollution category - handle both string and object formats
    String pollutionCategory = 'Pollution';
    if (json['pollution_category'] != null) {
      if (json['pollution_category'] is Map) {
        pollutionCategory = json['pollution_category']['pollution_category']?.toString() ?? 
                           json['pollution_category']['name']?.toString() ?? 
                           'Pollution';
      } else {
        pollutionCategory = json['pollution_category'].toString();
      }
    } else if (json['category'] != null) {
      pollutionCategory = json['category'].toString();
    } else if (json['report_type'] != null) {
      pollutionCategory = json['report_type'].toString();
    }

    // Extract description - ensure it's a clean string
    String descriptionText = 'No description available';
    if (json['detail'] != null) {
      descriptionText = json['detail'].toString();
    } else if (json['description'] != null) {
      descriptionText = json['description'].toString();
    } else if (json['details'] != null) {
      descriptionText = json['details'].toString();
    }

    return ReportItem(
      id: json['complaint_id']?.toString() ?? 
          json['id']?.toString() ?? 
          json['complaintId']?.toString(),
      reportId: json['report_id']?.toString(), // Store report_id separately
      title: json['title']?.toString() ?? 
             json['report_id']?.toString() ??
             pollutionCategory,
      reportType: pollutionCategory,
      status: status,
      description: descriptionText,
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

  /// Fetch complaints from API and filter by current user ID
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

      // Fetch all complaints from API
      final response = await httpClient.get(
        ApiConstants.complaintsEndpoint,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'accept': '*/*',
          },
        ),
      );
      print('Complaints API Response: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Handle different response formats
        List<dynamic> complaintsList = [];
        
        if (data is List) {
          complaintsList = data;
        } else if (data is Map) {
          // Check for nested data first (API returns {success: true, count: 36, data: [...]})
          if (data['data'] is List) {
            complaintsList = data['data'];
          } else if (data['complaints'] is List) {
            complaintsList = data['complaints'];
          } else {
            // Single complaint object
            complaintsList = [data];
          }
        }

        // Filter complaints to only show those belonging to the current user
        // Match customer_id with the current user's ID
        final userComplaints = complaintsList.where((complaint) {
          if (complaint is! Map) return false;
          final complaintCustomerId = complaint['customer_id']?.toString();
          return complaintCustomerId == userId.toString();
        }).toList();

        // Convert to ReportItem list
        allReports.assignAll(
          userComplaints.map((json) => ReportItem.fromJson(
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
