import 'package:eprs/app/modules/bottom_nav/bindings/bottom_nav_binding.dart';
import 'package:eprs/app/modules/bottom_nav/views/bottom_nav_view.dart';
import 'package:get/get.dart';

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOM_NAV,
      page: () => BottomNavBar(),
      binding: BottomNavBinding(),
    ),
  ];
}
