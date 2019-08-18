import 'package:alarm_ta/model/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DayPickerPage extends StatefulWidget {
  final List<String> pickedDays;

  const DayPickerPage({Key key, @required this.pickedDays}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPickerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Hari'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.of(context).pop(widget.pickedDays);
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: allDays.length,
        itemBuilder: (ctx, idx) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(allDays[idx]),
            ),
            Switch(
              value: widget.pickedDays.contains(allDays[idx]),
              onChanged: (val) {
                if (!mounted) return;
                setState(() {
                  if (widget.pickedDays.contains(allDays[idx])) {
                    widget.pickedDays.remove(allDays[idx]);
                  } else {
                    widget.pickedDays.add(allDays[idx]);
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
