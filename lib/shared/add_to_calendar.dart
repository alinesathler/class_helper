import 'package:device_calendar/device_calendar.dart';
import '../helpers/event_store.dart';
import 'package:flutter/foundation.dart';

Future<bool> AddToCalendar(List<Event> events) async {
  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  // Retrieve previously saved event IDs from the file
  List<String> _createdEventIds = await EventStorage.loadEventIds();

  // Retrieve calendars
  final _calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

  if (_calendarsResult.isSuccess && _calendarsResult.data != null) {
    // Iterate over all calendars
    for (var calendar in _calendarsResult.data!) {
      // Delete previously created events
      for (String eventId in _createdEventIds) {
        await _deviceCalendarPlugin.deleteEvent(calendar.id, eventId);
        debugPrint('Event deleted: $eventId');
      }
    }

    // Clear the list of created event IDs
    _createdEventIds.clear();

    // Create new events in all calendars
    for (var calendar in _calendarsResult.data!) {
      for (Event event in events) {
        event.calendarId = calendar.id; // Set the calendar ID for the event
        final result = await _deviceCalendarPlugin.createOrUpdateEvent(Event(
          event.calendarId,
          title: event.title,
          description: event.description,
          start: event.start,
          end: event.end,
          allDay: event.allDay,
          location: event.location,
          recurrenceRule: event.recurrenceRule,
        ));
        if (result!.isSuccess && result.data != null) {
          _createdEventIds.add(result.data!); // Store the event ID
          debugPrint('Event created: ${result.data}');
        } else {
          return false; // Return false if any event creation fails
        }
      }
    }

    await EventStorage.saveEventIds(
        _createdEventIds); // Save the event IDs to a file

    return true; // Return true if all events are created successfully
  }

  return false; // Return false if calendar retrieval fails
}
