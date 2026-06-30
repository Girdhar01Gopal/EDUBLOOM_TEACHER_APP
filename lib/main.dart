import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';
import 'package:teacher_app_edubloom/view_model/login_view_model.dart';

import 'firebase_options.dart';
import 'infrastructures/routes/page_constants.dart';
import 'infrastructures/routes/page_routes.dart';
import 'infrastructures/utils/language.dart';
import 'infrastructures/utils/local_storage/init_value.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init(); // ✅ MUST

  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request required permissions (e.g., storage, notifications)
  await Permission.storage.request();
  await Permission.notification.request(); // For notification permission

  InitVariables().onInit();

  // Set device preferred orientations (lock orientation)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // Firebase background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(480, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TEACHER APP EDUBLOOM',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF36474f)),
              useMaterial3: true,
            ),
            translations: Language(),
            locale: Locale('en', 'US'),
            fallbackLocale: Locale('en', 'US'),
            initialRoute: RouteName.splash_screen,
            getPages: AppRoutes.appRoutes(),
          );
        },
      ),
    );
  }
}