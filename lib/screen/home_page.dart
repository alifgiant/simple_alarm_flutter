import 'dart:isolate';

import 'package:alarm_ta/model/app_state.dart';
import 'package:alarm_ta/model/reminder.dart';
import 'package:alarm_ta/screen/schedule_add.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyHomeState();
  }
}

class MyHomeState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  List<MyEvent> appStateEvents = [];

  bool hasLoadFromDb = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    loadData();
  }

  void printHello() {
    final DateTime now = DateTime.now();
    final int isolateId = Isolate.current.hashCode;
    print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (builder) => MyHomePage()),
      (_) => false, // clean all back stack
    );
  }

  void loadData() async {
    if (!hasLoadFromDb) {
      await AppStateContainer.of(context).loadFromDb();
      hasLoadFromDb = true;
    }

    if (!mounted) return;
    setState(() {
      appStateEvents = AppStateContainer.of(context).readEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pentas'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext ctx) {
                return HomeMenus();
              });
        },
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 26.0),
            height: 330,
            child: CalendarCarousel<Event>(
              onDayPressed: (DateTime date, List<Event> l) {
                if (!mounted) return;
                setState(() => _selectedDate = date);
              },
              weekendTextStyle: TextStyle(
                color: Colors.red,
              ),
              locale: 'id',
              thisMonthDayBorderColor: Colors.grey,
              showHeaderButton: false,
              selectedDateTime: _selectedDate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Daftar Jadwal', style: TextStyle(fontSize: 16)),
          ),
          getScheduleList()
        ],
      ),
    );
  }

  Widget getScheduleList() {
    final dayName = DateFormat.EEEE('id').format(_selectedDate);
    final filteredEvents =
        appStateEvents.where((event) => event.days.contains(dayName)).toList();

    if (filteredEvents.length > 0) {
      return Expanded(
        child: ListView.builder(
          itemCount: filteredEvents.length,
          itemBuilder: (ctx, idx) => createScheduleRow(filteredEvents[idx]),
        ),
      );
    } else {
      return Expanded(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            'Tidak ada jadwal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Widget createScheduleRow(MyEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: InkWell(
        onTap: () => onClick(event),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Icon(event.reminder.icons),
              Container(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(event.reminder.key),
                  if (event.desc.isNotEmpty)
                    Text(
                      event.desc,
                      style: TextStyle(fontWeight: FontWeight.w300),
                    )
                ],
              ),
              Expanded(child: Container()),
              Text("${DateFormat.Hm().format(event.time)}"),
            ],
          ),
        ),
      ),
    );
  }

  void onClick(MyEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) => SchedulePage(
          title: event.reminder.key.toUpperCase(),
          event: event,
        ),
      ),
    );
  }
}

class HomeMenus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: reminderKinds.length,
      itemBuilder: (ctx, idx) => FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: Colors.black12),
        ),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(reminderKinds[idx].icons),
            Container(height: 8),
            Text(reminderKinds[idx].key, textAlign: TextAlign.center)
          ],
        ),
        onPressed: () => onClick(context, idx),
      ),
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
    );
  }

  void onClick(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (builder) => SchedulePage(
          title: reminderKinds[index].key.toUpperCase(),
          event: MyEvent(reminderKinds[index], List.from(allDays), null),
        ),
      ),
    );
  }
}
