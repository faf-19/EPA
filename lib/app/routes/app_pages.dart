import 'package:eprs/app/modules/report/views/report_issue_view.dart';
import 'package:eprs/app/modules/report/views/report_otp_view.dart';
import 'package:eprs/app/modules/report/views/report_success_view.dart';
import '../modules/report/controllers/report_otp_controller.dart';
import 'package:get/get.dart';

import '../modules/about/bindings/about_binding.dart';
import '../modules/about/views/about_view.dart';
import '../modules/awareness/bindings/awareness_binding.dart';
import '../modules/awareness/views/awareness_view.dart';
import '../modules/contact_us/bindings/contact_us_binding.dart';
import '../modules/contact_us/views/contact_us_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/language/bindings/language_binding.dart';
import '../modules/language/views/language_view.dart';
import '../modules/office/bindings/office_binding.dart';
import '../modules/office/views/office_view.dart';
import '../modules/office_detail_map_view/bindings/office_detail_map_view_binding.dart';
import '../modules/office_detail_map_view/views/office_detail_map_view.dart';
import '../modules/report/bindings/report_binding.dart';
import '../modules/report/views/report_view.dart';
import '../modules/setting/bindings/setting_binding.dart';
import '../modules/setting/views/privacy_policy_view.dart';
import '../modules/setting/views/setting_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/status/bindings/status_binding.dart';
import '../modules/status/views/status_view.dart';
import '../modules/term_and_conditions/views/term_and_conditions_view.dart';
import '../modules/signup/bindings/signup_binding.dart';
import '../modules/signup/views/signup_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: _Paths.SETTING,
      page: () => const SettingView(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: _Paths.LANGUAGE,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: _Paths.OFFICE,
      page: () => const OfficeView(),
      binding: OfficeBinding(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
    ),
    GetPage(name: _Paths.Privacy_Policy, page: () => const PrivacyPolicyView()),
    GetPage(
      name: _Paths.TERM_AND_CONDITIONS,
      page: () => const TermAndConditionsView(),
    ),
    GetPage(
      name: _Paths.CONTACT_US,
      page: () => const ContactUsView(),
      binding: ContactUsBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: _Paths.OFFICE_DETAIL_MAP_VIEW,
      page: () {
        final arg = Get.arguments;
        final officeName = (arg is String) ? arg : 'Addis Ketema';
        return OfficeDetailMapView(officeName: officeName);
      },
      binding: OfficeDetailMapViewBinding(),
    ),
    GetPage(
      name: _Paths.STATUS,
      page: () => const StatusView(),
      binding: StatusBinding(),
    ),
    GetPage(
      name: _Paths.AWARENESS,
      page: () => const AwarenessView(),
      binding: AwarenessBinding(),
    ),
    // GetPage(
    //   name: _Paths.LOGIN,
    //   page: () => const LoginView(),
    //   binding: LoginBinding(),
    // ),
    GetPage(
      name: _Paths.SIGNUP,
      page: () => SignUpOverlay(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () {
        final arg = Get.arguments;
        final reportType = (arg is String) ? arg : '';
        return ReportView(reportType: reportType);
      },
      binding: ReportBinding(),
    ),

    GetPage(name: _Paths.REPORT_ISSUE, page: () => const ReportIssueView()),

    GetPage(
      name: _Paths.Report_Success,
      page: () {
        final arg = Get.arguments;
        final reportId = (arg is String) ? arg : '';
        final date = DateTime.now();
        return ReportSuccessView(reportId: reportId, dateTime: date);
      },
    ),

    GetPage(
      name: _Paths.Report_Otp,
      page: () => const ReportOtpView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportOtpController>(() => ReportOtpController());
      }),
    ),
  ];
}
