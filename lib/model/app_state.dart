import 'dart:convert';

import 'package:alarm_ta/model/reminder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateContainer extends InheritedWidget {
  final List<MyEvent> _events;
  final Widget child;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AppStateContainer(this._events, this.child);

  Future<void> setupNotification(MyEvent event) async {
    var time = new Time(event.time.hour, event.time.minute, 0);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'pentas_alarm', 'Pentas Alarm', 'Alarm penjadwalan aktivitas');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    for (var i = 0; i < event.days.length; i++) {
      final dayId = event.days[i];

      Day day = Day.Monday;
      if (dayId == 'Senin') {
        day = Day.Monday;
      } else if (dayId == 'Selasa') {
        day = Day.Tuesday;
      } else if (dayId == 'Rabu') {
        day = Day.Wednesday;
      } else if (dayId == 'Kamis') {
        day = Day.Thursday;
      } else if (dayId == 'Jumat') {
        day = Day.Friday;
      } else if (dayId == 'Sabtu') {
        day = Day.Saturday;
      } else if (dayId == 'Minggu') {
        day = Day.Sunday;
      }

      await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(event.id - i,
          event.reminder.key, event.desc, day, time, platformChannelSpecifics);
    }
  }

  Future<void> addEvent(MyEvent event, {MyEvent oldEvent}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // drop time hour:minute:millisec
    event.days[0] = DateTime(
      event.days[0].year,
      event.days[0].month,
      event.days[0].day,
    );
    event.days[1] = DateTime(
      event.days[1].year,
      event.days[1].month,
      event.days[1].day,
    );

    if (event.id != null) {
      _events.removeWhere((evn) => evn.id == event.id);
      // cancel all event before
      print('cancel but reset');
      for (var i = 0; i < oldEvent.days.length; i++) {
        await flutterLocalNotificationsPlugin.cancel(oldEvent.id - i);
      }
    }

    int counter = event.days.length;
    if (prefs.containsKey('eventCounter')) {
      counter += prefs.getInt('eventCounter');
    }
    event.id = counter;
    await prefs.setInt('eventCounter', counter);

    _events.add(event);
    _events.sort((evtA, evtB) => evtA.time.isBefore(evtB.time) ? -1 : 1);

    // save to pref
    final jsonList = _events.map((event) => event.toJson()).toList();
    final data = jsonEncode(jsonList);
    prefs.setString('schedule', data);

    // schedule reminder
    if (event.id != null) {}
    await setupNotification(event);
  }

  Future<void> saveFontSize(double size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', size);
  }

  Future<double> getFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double fontSize = 12;
    if (prefs.containsKey('fontSize')) {
      fontSize = prefs.getDouble('fontSize');
    }
    return fontSize;
  }

  void deleteEvent(MyEvent event) async {
    print(event);
    if (event.id == null) return;

    print(_events);
    _events.removeWhere((evn) {
      print(evn.id);
      print(event.id);
      return evn.id == event.id;
    });
    print(_events);

    // save to pref
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonList = _events.map((event) => event.toJson()).toList();
    final data = jsonEncode(jsonList);

    print(data);
    prefs.setString('schedule', data);

    // remove reminder
    print('cancel reminder');
    for (var i = 0; i < event.days.length; i++) {
      await flutterLocalNotificationsPlugin.cancel(event.id - i);
    }
  }

  Future<List<MyEvent>> loadFromDb() async {
    // load from pref
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('schedule');
    if (data != null) {
      final jsonList = jsonDecode(data) as List<dynamic>;
      final events = jsonList.map((item) => MyEvent.parseJson(item)).toList();
      _events.clear();
      _events.addAll(events);
    }
    return _events;
  }

  List<MyEvent> readEvents() => _events;

  static AppStateContainer of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppStateContainer);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
