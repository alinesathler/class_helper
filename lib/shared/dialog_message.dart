import 'package:flutter/material.dart';

// Method to show error dialog
void ShowMessageDialog(String title, String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("OK"),
        ),
      ],
    ),
  );
}
