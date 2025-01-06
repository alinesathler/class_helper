import 'package:device_calendar/device_calendar.dart';
import '../models/class.dart';
import '../models/course.dart';
import '../models/institution.dart';
import '../models/program.dart';
import '../models/term.dart';

List<Event> AddClasses(List<Class> checkedClasses, Location currentLocation) {
  final List<Event> events = [];

  List<Institution> _listOfInstitutions =
      InstitutionService.getAllInstitutions();
  List<Program> _listOfPrograms = ProgramService.getAllPrograms();
  List<Term> _listOfTerms = TermService.getAllTerms();
  List<Course> _listOfCourses = CourseService.getAllCourses();

  for (var checkedClass in checkedClasses) {
    String title = _listOfCourses
        .firstWhere((c) => c.courseId == checkedClass.courseId)
        .code;

    String description = _listOfCourses
            .firstWhere((c) => c.courseId == checkedClass.courseId)
            .name +
        '\n' +
        _listOfCourses
            .firstWhere((c) => c.courseId == checkedClass.courseId)
            .professor +
        '\n' +
        checkedClass.room.toString();

    DateTime startDate = _listOfTerms
        .firstWhere((t) =>
            t.termId ==
            _listOfCourses
                .firstWhere((c) => c.courseId == checkedClass.courseId)
                .termId)
        .startDate;

    // Calculate the next occurrence of the class
    int dayOfWeek = checkedClass.dayOfWeek;
    int difference = (dayOfWeek - startDate.weekday + 7) % 7;
    startDate = startDate.add(Duration(days: difference));

    DateTime startDateWithTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        checkedClass.startTime.hour,
        checkedClass.startTime.minute);

    DateTime endDate = _listOfTerms
        .firstWhere((t) =>
            t.termId ==
            _listOfCourses
                .firstWhere((c) => c.courseId == checkedClass.courseId)
                .termId)
        .endDate;

    DateTime endDateWithTimeFirstClass = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        checkedClass.endTime.hour,
        checkedClass.endTime.minute);

    String address = checkedClass.isOnline
        ? ''
        : _listOfInstitutions
            .firstWhere((i) =>
                i.institutionId ==
                _listOfPrograms
                    .firstWhere((p) =>
                        p.programId ==
                        _listOfTerms
                            .firstWhere((t) =>
                                t.termId ==
                                _listOfCourses
                                    .firstWhere((c) =>
                                        c.courseId == checkedClass.courseId)
                                    .termId)
                            .programId)
                    .institutionId)
            .address;

    // Get the local timezone
    TZDateTime TZstartDateWithTime =
        TZDateTime.from(startDateWithTime, currentLocation);
    TZDateTime TZendDateWithTimeFirstClass =
        TZDateTime.from(endDateWithTimeFirstClass, currentLocation);

    // Create an event
    events.add(Event(
      'primary',
      title: title,
      description: description,
      start: TZstartDateWithTime,
      end: TZendDateWithTimeFirstClass,
      location: address,
      allDay: false,
      recurrenceRule: RecurrenceRule(
        RecurrenceFrequency.Weekly,
        endDate: endDate,
      ),
    ));
  }

  return events;
}
