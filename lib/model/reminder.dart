import 'package:flutter/material.dart';

class Reminder {
  final String key;
  final String buttonImage;
  final IconData icons;

  Reminder(this.key, this.buttonImage, this.icons);
}

class MyEvent {
  final Reminder reminder;
  final List<String> days;
  final DateTime time;
  final String desc;
  int id;

  MyEvent(this.reminder, this.days, this.time, {this.desc, this.id});

  Map<String, dynamic> toJson() {
    return {
      "reminder": reminder.key,
      "days": days.join(","),
      "time": time.toString(),
      "id": id,
      "desc": desc
    };
  }

  factory MyEvent.parseJson(Map<String, dynamic> data) {
    final reminder =
        reminderKinds.where((kind) => kind.key == data['reminder']).first;
    final days = data['days'].toString().split(',');
    final time = DateTime.tryParse(data['time']);
    final id = data['id'];
    final desc = data['desc'];
    return MyEvent(reminder, days, time, id: id, desc: desc);
  }
}

final allDays = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

final reminderKinds = [
  Reminder(
    'Minum Obat',
    'images/menu_medicine.png',
    Icons.local_pharmacy,
  ),
  Reminder(
    'Makan Minum',
    'images/menu_meal.png',
    Icons.restaurant,
  ),
  Reminder(
    'Bayar Tagihan',
    'images/menu_bill.png',
    Icons.payment,
  ),
  Reminder(
    'Arisan',
    'images/menu_arisan.png',
    Icons.people,
  ),
  Reminder(
    'Lainnya',
    'images/menu_add.png',
    Icons.add_alert,
  )
];
