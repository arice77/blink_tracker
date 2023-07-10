import 'dart:async';
import 'package:blink_tracker/Pages/abin_page.dart';
import 'package:blink_tracker/Pages/analytics_page.dart';
import 'package:blink_tracker/Pages/home_page.dart';
import 'package:blink_tracker/blink_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Services/forefround_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await Permission.camera.request().isGranted) {
    await initializeService();
  }
  await Permission.ignoreBatteryOptimizations.request();

  runApp(ChangeNotifierProvider(
      create: (context) => BlinkProvider(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
  static String routeName = 'homepage';
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool letLoad = (DateTime.now().isAfter(DateTime(2023, 7, 11)) ||
          DateTime.now() == DateTime(2023, 7, 11))
      ? false
      : true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        MyApp.routeName: (context) => const MyApp(),
        '/analytics': (context) => const MyHomePage(),
      },
      theme: ThemeData(useMaterial3: true),
      home: letLoad ? const HomePage() : const AbinPage(),
    );
  }
}
