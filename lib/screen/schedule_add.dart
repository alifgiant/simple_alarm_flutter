import 'package:alarm_ta/model/app_state.dart';
import 'package:alarm_ta/model/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:recase/recase.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class SchedulePage extends StatefulWidget {
  final String title;
  final MyEvent event;
  final double fontSize;

  const SchedulePage({
    Key key,
    this.title,
    this.event,
    this.fontSize,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SchedulePageState();
}

class SchedulePageState extends State<SchedulePage> {
  TextEditingController _controller = TextEditingController();
  DateTime _pickedTime = DateTime.now();
  List<DateTime> _pickedDate = [
    DateTime.now(),
    DateTime.now().add(Duration(days: 7)),
  ];
  String _desc = '';

  @override
  void initState() {
    super.initState();
    if (widget.event.time != null) _pickedTime = widget.event.time;
    if (widget.event.days != null) _pickedDate = widget.event.days;
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
          Builder(
            builder: (ctx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: buildActionButton(
                'Tanggal',
                getDaySelected(),
                () => showCalendarPicker(ctx),
              ),
            ),
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
                    _pickedDate,
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

  void showCalendarPicker(BuildContext ctx) async {
    final pickedDate = await DateRagePicker.showDatePicker(
      context: ctx,
      initialFirstDate: _pickedDate[0],
      initialLastDate: _pickedDate[1],
      firstDate: new DateTime(2000),
      lastDate: new DateTime(2040),
    );
    if (pickedDate == null) {
      return;
    } else {
      if (pickedDate.length == 1) {
        pickedDate.add(pickedDate[0]);
      }
      setState(() {
        _pickedDate = pickedDate;
      });
    }
  }

  String getDaySelected() {
    final start = _pickedDate[0];
    final stop = _pickedDate[1];
    final startStr = DateFormat.yMMMd().format(start);
    final stopStr = DateFormat.yMMMd().format(stop);
    return (startStr == stopStr) ? '$startStr' : '$startStr - $stopStr';
  }
}
