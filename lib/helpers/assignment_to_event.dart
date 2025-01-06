import 'package:device_calendar/device_calendar.dart';
import '../models/assignment.dart';
import '../models/course.dart';

List<Event> AddAssignments(
    List<Assignment> checkedAssignments, Location currentLocation) {
  final List<Event> events = [];

  List<Course> _listOfCourses = CourseService.getAllCourses();

  for (var checkedAssignment in checkedAssignments) {
    String title = _listOfCourses
        .firstWhere((c) => c.courseId == checkedAssignment.courseId)
        .code;

    String description = checkedAssignment.name;

    DateTime dueDate = checkedAssignment.dueDate;

    // Get the local timezone
    TZDateTime TZDueDateWithTime = TZDateTime.from(dueDate, currentLocation);

    // Create an event
    events.add(Event(
      'primary',
      title: title,
      description: description,
      start: TZDueDateWithTime,
      end: TZDueDateWithTime,
      allDay: true,
    ));
  }

  return events;
}
