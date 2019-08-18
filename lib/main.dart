import 'package:alarm_ta/model/app_state.dart';
import 'package:alarm_ta/screen/home_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void setupNotification() {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid =
      new AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = new IOSInitializationSettings();
  var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

void main() async {
  setupNotification();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id');
    return AppStateContainer(
      [],
      MaterialApp(
        title: 'Penjadwalan Aktivitas',
        home: SplashPage(),
      ),
    );
  }
}

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => MyHomePage()),
        (_) => false, // clean all back stack
      );
    });
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 246, 1),
      body: Center(child: Image.asset('images/logo_splash.png')),
    );
  }
}
