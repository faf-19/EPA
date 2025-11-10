// lib/app/modules/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:get_storage/get_storage.dart';

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
    'assets/image1.png': 'Foreign employment system in development',
    'assets/image2.png': 'New benefits outlined for employment',
    'assets/image3.png': 'Training programs launched',
    'assets/image4.png': 'Progress in employment system',
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

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();   // ← FIXED: No more LoginController
    _initMockComments();
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