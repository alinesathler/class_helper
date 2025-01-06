import 'package:flutter/material.dart';

class PickATime{
      // Method to pick a time
  static Future<TimeOfDay?> SelectTime(BuildContext context, TimeOfDay? time) async {
    TimeOfDay currentTime = time ?? TimeOfDay.now();
    TimeOfDay selectedTime = await showTimePicker(
          context: context,
          initialTime: currentTime,
        ) ??
        currentTime;
    return selectedTime;
  }
}