import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../network/dio_client.dart';

/// Dependency Injection Container
/// This sets up all the dependencies for the application
class InjectionContainer {
  static Future<void> init() async {
    // Initialize GetStorage
    await GetStorage.init();

    // Register GetStorage
    Get.put<GetStorage>(GetStorage(), permanent: true);

    // Register Dio Client
    Get.put<DioClient>(DioClient.instance, permanent: true);

    // Register Data Sources
    Get.put<AuthRemoteDataSource>(
      AuthRemoteDataSourceImpl(
        dio: Get.find<DioClient>().dio,
      ),
      permanent: true,
    );

    Get.put<AuthLocalDataSource>(
      AuthLocalDataSourceImpl(
        storage: Get.find<GetStorage>(),
      ),
      permanent: true,
    );

    // Register Repositories
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
        localDataSource: Get.find<AuthLocalDataSource>(),
      ),
      permanent: true,
    );

    // Register Use Cases
    Get.put<LoginUseCase>(
      LoginUseCase(
        Get.find<AuthRepository>(),
      ),
      permanent: true,
    );
  }
}

