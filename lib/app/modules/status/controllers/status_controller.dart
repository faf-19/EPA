import 'package:get/get.dart';

class ReportItem {
  final String title;
  final String status;
  final String description;
  final String date;

  ReportItem({
    required this.title,
    required this.status,
    required this.description,
    required this.date,
  });
}

class StatusController extends GetxController {
  // simple counter left for possible future use
  final count = 0.obs;

  /// Current selected filter (All, Pending, In Progress, Completed, Rejected)
  var selectedFilter = 'All'.obs;

  /// All reports (in a real app this would come from a repository)
  final RxList<ReportItem> allReports = <ReportItem>[].obs;

  /// Filtered reports exposed to the view
  final RxList<ReportItem> filteredReports = <ReportItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Seed some example data that matches the UI
    allReports.addAll([
      ReportItem(
        title: 'Family Registration',
        status: 'Pending',
        description:
            'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
        date: 'June 29, 2025 12:00 AM',
      ),
      ReportItem(
        title: 'Resident ID',
        status: 'In Progress',
        description:
            'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
        date: 'June 29, 2025 12:00 AM',
      ),
      ReportItem(
        title: 'Resident Transfer',
        status: 'Completed',
        description:
            'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
        date: 'June 29, 2025 12:00 AM',
      ),
      ReportItem(
        title: 'Unmarried',
        status: 'Completed',
        description:
            'I saw a man throwing trash on the street near [location]. I am reporting this so that appropriate action can be taken to keep our community clean. I saw a man throwing trash on the street near [location]. I am reporting this so...',
        date: 'June 29, 2025 12:00 AM',
      ),
      ReportItem(
        title: 'Rejected Case',
        status: 'Rejected',
        description:
            'This report was reviewed and rejected due to insufficient evidence. If you have additional information, please re-submit with clearer details or photos.',
        date: 'June 30, 2025 09:15 AM',
      ),
    ]);

    // initialize filtered list
    applyFilter();
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
