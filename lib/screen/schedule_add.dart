import 'package:alarm_ta/model/app_state.dart';
import 'package:alarm_ta/model/reminder.dart';
import 'package:alarm_ta/screen/day_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';

class SchedulePage extends StatefulWidget {
  final String title;
  final MyEvent event;
  final double fontSize;

  const SchedulePage({Key key, this.title, this.event, this.fontSize})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  TextEditingController _controller = TextEditingController();
  DateTime _pickedTime = DateTime.now();
  String _desc = '';
  List<String> _pickedDays = List.from(allDays);

  @override
  void initState() {
    super.initState();
    if (widget.event.time != null) _pickedTime = widget.event.time;
    if (widget.event.days != null) _pickedDays = widget.event.days;
    if (widget.event.desc != null) _desc = widget.event.desc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ReCase(widget.title).titleCase)),
      body: ListView(
        children: <Widget>[
          Container(height: 18),
          Center(child: Icon(widget.event.reminder.icons, size: 80)),
          Container(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              maxLines: 1,
              controller: _controller..text = _desc,
              onChanged: (str) => _desc = str,
              style: TextStyle(fontSize: widget.fontSize),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  labelText: 'Detail Kegiatan',
                  hasFloatingPlaceholder: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  )),
            ),
          ),
          Container(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: buildActionButton('Setiap', getDaySelected(), () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (ctx) => DayPickerPage(
                            pickedDays: _pickedDays,
                          )));
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: buildActionButton(
              'Setiap Jam',
              _pickedTime == null
                  ? '00:00'
                  : '${DateFormat.Hm().format(_pickedTime)}',
              showTimePicker,
            ),
          ),
          Container(height: 120),
          Center(
            child: RaisedButton(
              color: Colors.cyan,
              child: Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                ),
              ),
              onPressed: () async {
                await AppStateContainer.of(context).addEvent(
                  MyEvent(
                    widget.event.reminder,
                    _pickedDays,
                    _pickedTime,
                    desc: _controller.text,
                    id: widget.event.id,
                  ),
                  oldEvent: widget.event,
                );
                if (widget.event.id == null) Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ),
          if (widget.event.id != null)
            Center(
              child: RaisedButton(
                color: Colors.amberAccent,
                child: Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.fontSize,
                  ),
                ),
                onPressed: () {
                  AppStateContainer.of(context).deleteEvent(widget.event);
                  Navigator.of(context).pop();
                },
              ),
            ),
        ],
      ),
    );
  }

  FlatButton buildActionButton(
    String caption,
    String selection,
    VoidCallback callback,
  ) {
    return FlatButton(
      onPressed: callback,
      color: Colors.blue,
      child: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                caption,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                ),
              ),
              Expanded(child: Container()),
              Text(
                selection,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void showDayPicker() async {
    List<String> picked = List.from(_pickedDays);
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: allDays.length,
          itemBuilder: (ctx, idx) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(allDays[idx]),
              ),
              Checkbox(
                value: picked.contains(allDays[idx]),
                onChanged: (val) {
                  if (!mounted) return;
                  setState(() {
                    if (val && !picked.contains(allDays[idx])) {
                      picked.add(allDays[idx]);
                    } else if (picked.contains(allDays[idx])) {
                      picked.remove(allDays[idx]);
                    }
                  });
                },
              )
            ],
          ),
        );
      },
    );
  }

  void showTimePicker() {
    DatePicker.showDatePicker(
      context,
      dateFormat: 'HH:mm',
      pickerMode: DateTimePickerMode.time,
      onConfirm: (date, list) {
        if (!mounted) return;
        setState(() {
          _pickedTime = date;
        });
      },
      pickerTheme: DateTimePickerTheme(
        cancel: Text('Batal'),
        confirm: Text('Simpan', style: TextStyle(color: Colors.blueAccent)),
      ),
    );
  }

  String getDaySelected() {
    if (_pickedDays.length == 7) return "Hari";
    return allDays.where((day) => _pickedDays.contains(day)).join(",");
  }
}
