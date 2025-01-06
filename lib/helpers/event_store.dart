import 'dart:io';
import '../shared/get_diretory.dart';

class EventStorage {
  // Save the event IDs to a file
  static Future<void> saveEventIds(List<String> eventIds) async {
    String path = await getFilePath();
    final file = File('$path/event_ids.txt');

    final data = eventIds.join('\n'); // Join event IDs with new lines
    await file.writeAsString(data);
  }

  // Load the event IDs from a file
  static Future<List<String>> loadEventIds() async {
    try {
      String path = await getFilePath();
      final file = File('$path/event_ids.txt');

      if (file.existsSync()) {
        final data = await file.readAsString();
        return data.split('\n');
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
