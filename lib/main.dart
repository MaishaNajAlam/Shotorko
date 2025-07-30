import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'splash_screen.dart';
import 'alert_received_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();
  runApp(ShotorkoApp());
}

class ShotorkoApp extends StatefulWidget {
  @override
  _ShotorkoAppState createState() => _ShotorkoAppState();
}

class _ShotorkoAppState extends State<ShotorkoApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() {
    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      final data = message.data;
      final userName = data['userName'] ?? 'Unknown';
      final lat = double.tryParse(data['lat'] ?? '0.0') ?? 0.0;
      final lng = double.tryParse(data['lng'] ?? '0.0') ?? 0.0;
      final timestamp = data['timestamp'] ?? 'Unknown';

      // Show alert dialog in foreground
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (_) => AlertDialog(
          title: Text(notification?.title ?? 'Emergency Alert'),
          content: Text(notification?.body ??
              'Your contact $userName needs help urgently!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(navigatorKey.currentContext!).pop();
                navigatorKey.currentState?.push(MaterialPageRoute(
                  builder: (_) => AlertReceivedScreen(
                    userName: userName,
                    lat: lat,
                    lng: lng,
                    alertTime: timestamp,
                  ),
                ));
              },
              child: Text('Open'),
            )
          ],
        ),
      );
    });

    // Background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      final userName = data['userName'] ?? 'Unknown';
      final lat = double.tryParse(data['lat'] ?? '0.0') ?? 0.0;
      final lng = double.tryParse(data['lng'] ?? '0.0') ?? 0.0;
      final timestamp = data['timestamp'] ?? 'Unknown';

      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => AlertReceivedScreen(
          userName: userName,
          lat: lat,
          lng: lng,
          alertTime: timestamp,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Shotorko',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
