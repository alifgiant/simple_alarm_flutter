import 'package:alarm_ta/model/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  double value = 12;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    loadData();
  }

  void loadData() async {
    value = await AppStateContainer.of(context).getFontSize();

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
        actions: <Widget>[
          FlatButton(
            child: Text('Simpan', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await AppStateContainer.of(context).saveFontSize(value);
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Container(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text('Ukuran font', style: TextStyle(fontSize: value)),
          ),
          Slider(
            value: value,
            min: 10,
            max: 18,
            onChanged: (newValue) {
              setState(() {
                value = newValue;
              });
            },
          )
        ],
      ),
    );
  }
}
