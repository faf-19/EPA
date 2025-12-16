import 'package:eprs/domain/usecases/get_offices_usecase.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/office_remote_datasource.dart';
import '../../data/datasources/remote/awareness_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/office_repository_impl.dart';
import '../../data/repositories/awareness_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/office_repository.dart';
import '../../domain/repositories/awareness_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/get_awareness_usecase.dart';
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

    Get.put<SignupUseCase>(
      SignupUseCase(
        Get.find<AuthRepository>(),
      ),
      permanent: true,
    );

    Get.put<VerifyOtpUseCase>(
      VerifyOtpUseCase(
        Get.find<AuthRepository>(),
      ),
      permanent: true,
    );

    Get.put<ResendOtpUseCase>(
      ResendOtpUseCase(
        Get.find<AuthRepository>(),
      ),
      permanent: true,
    );

    // Register Office Data Sources
    Get.put<OfficeRemoteDataSource>(
      OfficeRemoteDatasourceImpl(
        dio: Get.find<DioClient>().dio,
        storage: Get.find<GetStorage>(),
      ),
      permanent: true,
    );

    // Register Office Repository
    Get.put<OfficeRepository>(
      OfficeRepositoryImpl(
        remoteDataSource: Get.find<OfficeRemoteDataSource>(),
      ),
      permanent: true,
    );

    // Register Office Use Cases
    Get.put<GetOfficesUsecase>(
      GetOfficesUsecase(
        repository: Get.find<OfficeRepository>(),
      ),
      permanent: true,
    );

    // Register Awareness Data Sources
    Get.put<AwarenessRemoteDataSource>(
      AwarenessRemoteDataSourceImpl(
        dio: Get.find<DioClient>().dio,
        storage: Get.find<GetStorage>(),
      ),
      permanent: true,
    );

    // Register Awareness Repository
    Get.put<AwarenessRepository>(
      AwarenessRepositoryImpl(
        remoteDataSource: Get.find<AwarenessRemoteDataSource>(),
      ),
      permanent: true,
    );

    // Register Awareness Use Cases
    Get.put<GetAwarenessUseCase>(
      GetAwarenessUseCase(
        repository: Get.find<AwarenessRepository>(),
      ),
      permanent: true,
    );
  }
}

