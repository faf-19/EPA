import 'package:flutter/material.dart';
//import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await FlutterDownloader.initialize();  // Initialize flutter_downloader here



  runApp(
    GetMaterialApp(
      title: "EPA",
      initialRoute: Routes.LOGIN, 
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
    ),
  );
}
