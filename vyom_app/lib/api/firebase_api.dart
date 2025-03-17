import "package:firebase_messaging/firebase_messaging.dart";
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class FirebaseApi {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Function to get the device ID
  static Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique Android ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor; // Unique iOS ID
    }
    return null;
  }

  // Handle background notifications
  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('📩 Notification Received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Get device ID and print it
    String? deviceId = await getDeviceId();
    print("📱 Device ID: $deviceId");
  }

  // Initialize Firebase Messaging and request permissions
  static Future<void> initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ Notifications allowed!");

      final token = await _firebaseMessaging.getToken();
      print("🔥 Firebase Messaging Token: $token");

      // Get device ID and print it after allowing notifications
      String? deviceId = await getDeviceId();
      print("📱 Device ID: $deviceId");

      // Listen for background messages
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    } else {
      print("❌ Notifications denied!");
    }
  }
}
