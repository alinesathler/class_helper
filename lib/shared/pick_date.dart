import 'package:flutter/material.dart';

class PickADate{
      // Method to pick a date
  static Future<DateTime?> SelectDate(BuildContext context, DateTime? date) async {
    DateTime currentDate = date ?? DateTime.now();
    DateTime selectedDate = await showDatePicker(
          context: context,
          initialDate: currentDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        ) ??
        currentDate;
    return selectedDate;
  }
}