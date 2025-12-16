import 'package:eprs/data/models/awareness_model.dart';
import 'package:eprs/domain/usecases/get_awareness_usecase.dart';
import 'package:get/get.dart';

class AwarenessController extends GetxController {
  final GetAwarenessUseCase getAwarenessUseCase;

  final RxList<AwarenessModel> awarenessList = <AwarenessModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  AwarenessController({required this.getAwarenessUseCase});

  @override
  void onInit() {
    super.onInit();
    loadAwareness();
  }

  Future<void> loadAwareness() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final awarenessItems = await getAwarenessUseCase.execute();
      awarenessList.assignAll(awarenessItems);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load awareness items: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get image URL for an awareness item
  String getImageUrl(AwarenessModel awareness) {
    if (awareness.filePath.isEmpty) return '';
    // Construct full URL from base URL and file path
    // The file_path from API is "public/awareness/1765441375918-272768571-env awareness.jpeg"
    // We need to remove the "public/" prefix from the URL
    const baseUrl = 'http://196.188.240.103:4032';
    
    String filePath = awareness.filePath;
    
    // Remove 'public/' prefix if present
    if (filePath.startsWith('public/')) {
      filePath = filePath.substring(7); // Remove 'public/' (7 characters)
    }
    
    // URL encode each path segment but keep slashes
    // This handles spaces in filenames like "env awareness.jpeg" -> "env%20awareness.jpeg"
    final pathSegments = filePath.split('/');
    final encodedSegments = pathSegments.map((segment) => Uri.encodeComponent(segment)).join('/');
    
    // Construct URL without the 'public/' prefix
    // Example: http://196.188.240.103:4032/awareness/1765441375918-272768571-env%20awareness.jpeg
    final imageUrl = '$baseUrl/$encodedSegments';
    
    // Debug: print the URL to help troubleshoot
    print('Awareness image URL: $imageUrl');
    print('Original file path: ${awareness.filePath}');
    
    return imageUrl;
  }
}
