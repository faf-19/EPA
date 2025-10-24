import 'package:get/get.dart';
import 'package:eprs/app/modules/bottom_nav/controllers/bottom_nav_controller.dart';
class HomeController extends GetxController {
  // Use non-final variables to allow assignment in onInit
  String userName = 'Guest'; // Default value
  String phoneNumber = ''; // Default value

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

  // Mockup data for posts
  final RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[
    {
      'userName': 'Admin User',
      'content': 'New environmental policy announced!',
      'imageUrl': 'assets/image1.png',
      'profileImage': 'assets/image3.png',
      'isAdmin': true,
    },
    {
      'userName': 'Admin Team',
      'content': 'Community cleanup scheduled for next Saturday. Join us!',
      'imageUrl': 'assets/image2.png',
      'profileImage': 'assets/image2.png',
      'isAdmin': true,
    },
    {
      'userName': 'Tensae Tefera',
      'content': 'Pothole on commercial road causing vehicle damage. Needs immediate attention',
      'imageUrl': 'assets/image3.png',
      'profileImage': 'assets/image1.png',
      'isAdmin': false,
    },
    {
      'userName': 'Admin Coordinator',
      'content': 'Recycling program launched in downtown area. Participate now!',
      'imageUrl': 'assets/image4.png',
      'profileImage': 'assets/images4.png',
      'isAdmin': true,
    },
    {
      'userName': 'Admin',
      'content': 'Recycling program launched in downtown area. Participate now!',
      'imageUrl': 'assets/image4.png',
      'profileImage': 'assets/images4.png',
      'isAdmin': true,
    },
  ].obs;

  // Getter for admin posts
  List<Map<String, dynamic>> get adminPosts => posts.where((post) => post['isAdmin'] == true).toList();

 @override
void onInit() {
  final bottomNavController = Get.find<BottomNavController>();
  userName = bottomNavController.username;
  phoneNumber = bottomNavController.phone;
  super.onInit();
}

}