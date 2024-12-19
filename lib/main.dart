/// **File Structure:**
/// - main.dart
/// - lib/
///   - home_screen.dart
/// - android/app/src/main/AndroidManifest.xml
/// - ios/Runner/Info.plist

// **File: main.dart**

import 'package:flutter/material.dart';
import 'package:google_map_task/service/notification_service.dart';
import 'package:provider/provider.dart';

import 'moduls/controller/home_provider.dart';
import 'moduls/screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  await NotificationService.requestNotificationPermission();

  // Request notification permission
  await NotificationService.requestNotificationPermission();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => HomeProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geofence App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
