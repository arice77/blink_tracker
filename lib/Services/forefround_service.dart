import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:blink_tracker/Services/blink_track_service.dart';
import 'package:camera_bg/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db_service.dart';

List<CameraDescription> cameras = [];
int blinkCount = 0;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: false,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Blink Tracker',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  // service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  BlinkTrack blinkTrack = BlinkTrack();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  cameras = await availableCameras();
  CameraController controller = CameraController(
      cameras.firstWhere(
          (element) => element.lensDirection == CameraLensDirection.front),
      ResolutionPreset.low,
      enableAudio: false);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    controller.stopImageStream();
    service.stopSelf();
  });

  DateTime lastMinute = DateTime.now();

  await controller.initialize().then((value) {
    controller.startImageStream((image) async {
      DateTime now = DateTime.now();

      if (now.difference(lastMinute).inMinutes >= 1) {
        var threshold = preferences.getInt('threshold') ?? 8;
        if (blinkCount < threshold) {
          flutterLocalNotificationsPlugin.show(
            Random().nextInt(1000),
            'Insuffecient Blinks',
            'You have not blinked $threshold times.',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                  'my_foregrounds', 'MY FOREGROUND SERVICEs',
                  icon: 'ic_bg_service_small',
                  enableVibration: false,
                  importance: Importance.high,
                  priority: Priority.high),
            ),
          );
        }
        insertBlinkData();

        // Reset the blink count
        blinkCount = 0;

        // Update the lastMinute variable
        lastMinute = now;
      }
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          InputImage? inputImage = blinkTrack.getInputImage(image);

          blinkTrack.imageProcess(inputImage);

          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          flutterLocalNotificationsPlugin.show(
            888,
            'Blink Tracker',
            'Blink Tracking',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'my_foreground',
                'MY FOREGROUND SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );

          // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "Blink Tracker",
            content: "Blink Tracking",
          );
        }
      }

      service.invoke(
        'update',
        {"blink": blinkCount},
      );
    });
  });

  // bring to foreground
}

insertBlinkData() async {
  await DBHelper.insert('blinks', {
    'id': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    'blinkCount': blinkCount,
    'time': DateFormat("HH:mm").format(DateTime.now())
  });
}
