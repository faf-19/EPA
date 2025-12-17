// lib/app/modules/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:eprs/core/network/dio_client.dart';
import 'package:eprs/core/constants/api_constants.dart';
import 'package:dio/dio.dart' as dio;
import '../../status/controllers/status_controller.dart';
import '../../status/views/status_detail_view.dart';

class HomeController extends GetxController {
  // === USER INFO (from GetStorage) ===
  final RxString userName = 'Guest'.obs;
  final RxString phoneNumber = ''.obs;
  final RxInt currentCarouselIndex = 0.obs;

  // Carousel controller lives on the HomeController so it is not recreated
  // every time the widget tree rebuilds. This prevents leaking controller
  // instances and preserves carousel state across rebuilds.
  final CarouselSliderController carouselCtrl = CarouselSliderController();

  // === Carousel Data ===
  final List<String> imageUrls = [
    'assets/image1.png',
    'assets/image2.png',
    'assets/image3.png',
    'assets/image4.png',
  ];

  final Map<String, String> imageCaptions = {
    'assets/image1.png': 'It was pointed out foreign employment is developing a system',
    'assets/image2.png': 'New benefits outlined for employment',
    'assets/image3.png': 'Training programs launched',
    'assets/image4.png': 'Progress in employment system',
  };

  final Map<String, String> imageDates = {
    'assets/image1.png': 'Nov 19',
    'assets/image2.png': 'Nov 18',
    'assets/image3.png': 'Nov 17',
    'assets/image4.png': 'Nov 16',
  };

  final Map<String, String> imageCities = {
    'assets/image1.png': 'Addis Ababa',
    'assets/image2.png': 'Addis Ababa',
    'assets/image3.png': 'Addis Ababa',
    'assets/image4.png': 'Addis Ababa',
  };

  // === Posts ===
  final RxList<Post> posts = <Post>[
    Post(
      id: 'p1',
      userName: 'Admin User',
      content: 'New environmental policy announced!',
      imageUrl: 'assets/image1.png',
      profileImage: 'assets/image3.png',
      isAdmin: true,
      timestamp: '2 hours ago',
      likes: 234,
      comments: 42,
    ),
    Post(
      id: 'p2',
      userName: 'Admin Team',
      content: 'Community cleanup scheduled for next Saturday. Join us!',
      imageUrl: 'assets/image2.png',
      profileImage: 'assets/image2.png',
      isAdmin: true,
      timestamp: '4 hours ago',
      likes: 156,
      comments: 28,
    ),
    Post(
      id: 'p3',
      userName: 'Tensae Tefera',
      content: 'Pothole on commercial road causing vehicle damage. Needs immediate attention',
      imageUrl: 'assets/image3.png',
      profileImage: 'assets/image1.png',
      isAdmin: false,
      timestamp: '6 hours ago',
      likes: 89,
      comments: 15,
    ),
    Post(
      id: 'p4',
      userName: 'Admin Coordinator',
      content: 'Recycling program launched in downtown area. Participate now!',
      imageUrl: 'assets/image4.png',
      profileImage: 'assets/image4.png',
      isAdmin: true,
      timestamp: '1 day ago',
      likes: 312,
      comments: 67,
    ),
  ].obs;

  // === Getters ===
  List<Post> get adminPosts => posts.where((p) => p.isAdmin).toList();
  List<Post> get userPosts => posts.where((p) => !p.isAdmin).toList();

  // === Comments ===
  final RxList<Comment> comments = <Comment>[].obs;
  final box = GetStorage();
  
  // === Pollution Categories ===
  final RxMap<String, String> pollutionCategories = <String, String>{}.obs; // Map of category name to ID
  
  // === Report ID Search ===
  final reportIdController = TextEditingController();
  var isSearchingReport = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();   // ← FIXED: No more LoginController
    _initMockComments();
    fetchPollutionCategories();
  }
  
  // Fetch pollution categories from API
  Future<void> fetchPollutionCategories() async {
    print('🔄 Starting to fetch pollution categories...');
    try {
      final httpClient = Get.find<DioClient>().dio;
      final token = box.read('auth_token');
      final res = await httpClient.get(
        ApiConstants.pollutionCategoriesEndpoint,
        options: dio.Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      
      print('📡 Pollution Categories API Response: ${res.data}');
      print('📡 Response Status Code: ${res.statusCode}');
      
      final data = res.data;
      List items = [];
      if (data is List) {
        items = data;
        print('✓ Categories data is a direct List with ${items.length} items');
      } else if (data is Map) {
        if (data['data'] is List) {
          items = data['data'];
          print('✓ Categories data found in "data" key with ${items.length} items');
        } else if (data['categories'] is List) {
          items = data['categories'];
          print('✓ Categories data found in "categories" key with ${items.length} items');
        } else {
          print('⚠️ Could not find categories array. Available keys: ${data.keys.toList()}');
        }
      }
      
      pollutionCategories.clear();
      for (var item in items) {
        if (item is Map) {
          final id = item['pollution_category_id']?.toString() ?? item['id']?.toString() ?? '';
          final name = item['pollution_category']?.toString() ?? item['name']?.toString() ?? '';
          if (id.isNotEmpty && name.isNotEmpty) {
            // Store multiple variations for flexible lookup
            final normalizedName = name.toLowerCase().trim();
            pollutionCategories[normalizedName] = id; // lowercase: "pollution"
            pollutionCategories[name.trim()] = id; // original case: "Pollution"
            pollutionCategories[name.trim().toLowerCase()] = id; // lowercase original: "pollution"
            
            // Also handle common variations
            if (normalizedName == 'pollution') {
              pollutionCategories['air pollution'] = id;
            }
            
            print('📋 Loaded category: "$name" (ID: $id)');
            print('   - Stored as: "$normalizedName", "${name.trim()}"');
          }
        }
      }
      
      print('✅ Loaded ${pollutionCategories.length} pollution category mappings');
      print('   Available keys: ${pollutionCategories.keys.toList()}');
    } catch (e, stackTrace) {
      print('❌ Error fetching pollution categories: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  // Get pollution category ID by name (handles various formats)
  String? getPollutionCategoryId(String categoryName) {
    print('🔍 Looking up pollution category for: "$categoryName"');
    
    // Normalize the input
    final normalized = categoryName.toLowerCase().trim();
    
    // Try direct lookup first
    var id = pollutionCategories[normalized];
    
    // If not found, try with capitalized first letter
    if (id == null && normalized.isNotEmpty) {
      final capitalized = normalized[0].toUpperCase() + normalized.substring(1);
      id = pollutionCategories[capitalized];
    }
    
    // If still not found, try exact match (case-insensitive)
    if (id == null) {
      for (var key in pollutionCategories.keys) {
        if (key.toLowerCase() == normalized) {
          id = pollutionCategories[key];
          break;
        }
      }
    }
    
    print('   Result: ${id != null ? "✅ Found ID: $id" : "❌ Not found"}');
    print('   Available categories: ${pollutionCategories.keys.toList()}');
    
    return id;
  }

  // FIXED: Load user from GetStorage (safe & fast)
  void _loadUserFromStorage() {
    userName.value = box.read('username') ?? 'Guest';
    phoneNumber.value = box.read('phone') ?? '';

    // Optional: Welcome toast
    if (userName.value != 'Guest') {
      Future.delayed(const Duration(seconds: 1), () {
        Get.snackbar(
          'Welcome back!',
          userName.value,
          backgroundColor: const Color(0xFF22C55E),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      });
    }
  }

  // Mock comments
  void _initMockComments() {
    comments.assignAll([
      Comment(
        id: 'c1',
        postId: 'p3',
        author: 'Selamawit Yilma',
        content: 'Thanks for reporting! This needs urgent attention.',
  // avatars folder isn't included in assets; use existing image assets as fallback
  avatar: 'assets/image1.png',
        timestamp: '1 hour ago',
        likes: 45,
        isLiked: false,
        replies: [
          Comment(
            id: 'c1-r1',
            postId: 'p3',
            author: 'Road Authority',
            content: 'We\'re on it. Crew dispatched.',
            avatar: 'assets/image2.png',
            timestamp: '30 min ago',
            likes: 12,
            isLiked: false,
            replies: [],
          ),
        ],
      ),
      Comment(
        id: 'c2',
        postId: 'p3',
        author: 'Kebede Lemma',
        content: 'I saw it yesterday. Very dangerous at night.',
  avatar: 'assets/image2.png',
        timestamp: '2 hours ago',
        likes: 23,
        isLiked: true,
        replies: [],
      ),
    ]);
  }

  // === Actions ===
  void togglePostLike(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post != null) {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      posts.refresh();
    }
  }

  void addComment(String postId, String content) {
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      author: userName.value == 'Guest' ? 'You (Guest)' : userName.value,
      content: content,
      avatar: 'assets/avatars/you.png',
      timestamp: 'Just now',
      likes: 0,
      isLiked: false,
      replies: [],
    );
    comments.insert(0, newComment);
    _incrementCommentCount(postId);
  }

  void _incrementCommentCount(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post != null) {
      post.comments++;
      posts.refresh();
    }
  }

  void toggleCommentLike(String commentId) {
    final comment = _findCommentById(commentId);
    if (comment != null) {
      comment.isLiked = !comment.isLiked;
      comment.likes += comment.isLiked ? 1 : -1;
      comments.refresh();
    }
  }

  void addReply(String parentCommentId, String content) {
    final parent = _findCommentById(parentCommentId);
    if (parent != null) {
      final reply = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: parent.postId,
        author: userName.value == 'Guest' ? 'You (Guest)' : userName.value,
        content: content,
        avatar: 'assets/avatars/you.png',
        timestamp: 'Just now',
        likes: 0,
        isLiked: false,
        replies: [],
      );
      parent.replies.insert(0, reply);
      comments.refresh();
    }
  }

  Comment? _findCommentById(String id) {
    for (var c in comments) {
      if (c.id == id) return c;
      final reply = c.replies.cast<Comment?>().firstWhere((r) => r?.id == id, orElse: () => null);
      if (reply != null) return reply;
    }
    return null;
  }

  List<Comment> getCommentsForPost(String postId) {
    return comments.where((c) => c.postId == postId).toList();
  }

  // === LOGOUT ===
  void logout() {
    box.erase();
    userName.value = 'Guest';
    phoneNumber.value = '';
    Get.offAllNamed('/splash');
  }

  // === SEARCH REPORT BY ID ===
  Future<void> searchReportById(String reportId) async {
    if (reportId.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a report ID',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isSearchingReport.value = true;

    try {
      final storage = Get.find<GetStorage>();
      final userId = storage.read('userId') ?? storage.read('user_id');
      final token = storage.read('auth_token');

      if (userId == null || token == null) {
        Get.snackbar(
          'Error',
          'Please login to search for reports',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isSearchingReport.value = false;
        return;
      }

      final httpClient = Get.find<DioClient>().dio;

      // Fetch all complaints and find the one with matching report_id
      final response = await httpClient.get(
        ApiConstants.complaintsEndpoint,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $token',
            'accept': '*/*',
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
          if (data['data'] is List) {
            complaintsList = data['data'];
          } else if (data['complaints'] is List) {
            complaintsList = data['complaints'];
          }
        }

        // Find complaint with matching report_id that belongs to current user
        dynamic foundComplaint;
        try {
          foundComplaint = complaintsList.firstWhere(
            (complaint) {
              if (complaint is! Map) return false;
              final complaintReportId = complaint['report_id']?.toString() ?? '';
              final complaintCustomerId = complaint['customer_id']?.toString();
              
              // Match report_id and verify it belongs to current user
              return complaintReportId.toLowerCase().trim() == reportId.toLowerCase().trim() &&
                     complaintCustomerId == userId.toString();
            },
          );
        } catch (e) {
          foundComplaint = null;
        }

        if (foundComplaint != null) {
          // Convert to ReportItem and navigate to detail view
          final reportItem = ReportItem.fromJson(
            foundComplaint is Map<String, dynamic> 
                ? foundComplaint 
                : Map<String, dynamic>.from(foundComplaint)
          );
          
          // Navigate to status detail view
          reportIdController.clear();
          Get.to(() => StatusDetailView(report: reportItem));
        } else {
          Get.snackbar(
            'Not Found',
            'Report ID not found or you do not have access to this report',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to search for report. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on dio.DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message']?.toString() ?? 
        'Failed to search for report. Please check your connection.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSearchingReport.value = false;
    }
  }

  @override
  void onClose() {
    reportIdController.dispose();
    super.onClose();
  }
}

// === MODELS ===
class Post {
  final String id;
  final String userName;
  final String content;
  final String imageUrl;
  final String profileImage;
  final bool isAdmin;
  final String timestamp;

  int likes;
  int comments;
  bool isLiked;

  Post({
    required this.id,
    required this.userName,
    required this.content,
    required this.imageUrl,
    required this.profileImage,
    required this.isAdmin,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });
}

class Comment {
  final String id;
  final String postId;
  final String author;
  final String content;
  final String avatar;
  final String timestamp;

  int likes;
  bool isLiked;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.avatar,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.replies = const [],
  });
}