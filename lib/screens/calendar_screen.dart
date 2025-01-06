import '../helpers/class_to_event.dart';
import '../helpers/assignment_to_event.dart';
import '../shared/add_to_calendar.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import '../models/institution.dart';
import '../models/program.dart';
import '../models/term.dart';
import '../models/course.dart';
import '../models/class.dart';
import '../models/assignment.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../shared/colors.dart';

class CalendarScreen extends StatefulWidget {
  CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Location? _currentLocation;

  final Map<int, bool> _expandedItems = {}; // Tracks expanded states

  // Create a list of events
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations;
    final locationName = _currentLocation = tz.getLocation(locations.keys.last);
    tz.setLocalLocation(locationName);
  }

  // Method to toggle expanded state
  void _toggleExpanded(int id) {
    setState(() {
      _expandedItems[id] = !(_expandedItems[id] ?? false);
    });
  }

  void toggleCheckedState(dynamic item) {
    item.isSelected = !item.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add to Calendar',
              style: TextStyle(color: MyColors.onSurface)),
        ),
        body: Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            if (InstitutionService.getAllInstitutions().isEmpty)
              Center(
                child: Text('No institutions found.'),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: InstitutionService.getAllInstitutions()
                          .map((institution) {
                        return ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Checkbox(
                                value: institution.isSelected,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    institution.isSelected = newValue ?? false;
                                    for (var program in ProgramService
                                        .getProgramsOfInstitution(
                                            institution.institutionId)) {
                                      program.isSelected =
                                          institution.isSelected;
                                      for (var term
                                          in TermService.getTermsOfProgram(
                                              program.programId)) {
                                        term.isSelected = program.isSelected;
                                        for (var course
                                            in CourseService.getCoursesOfTerm(
                                                term.termId)) {
                                          course.isSelected = term.isSelected;
                                          for (var assignment
                                              in AssignmentService
                                                  .getAssignmentsOfCourse(
                                                      course.courseId)) {
                                            assignment.isSelected =
                                                course.isSelected;
                                          }
                                          for (var classItem in ClassService
                                              .getClassesOfCourse(
                                                  course.courseId)) {
                                            classItem.isSelected =
                                                course.isSelected;
                                          }
                                        }
                                      }
                                    }
                                  });
                                },
                              ),
                              Expanded(child: Text(institution.name)),
                            ],
                          ),
                          children: ProgramService.getProgramsOfInstitution(
                                  institution.institutionId)
                              .map((program) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ExpansionTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Checkbox(
                                      value: program.isSelected,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          program.isSelected =
                                              newValue ?? false;
                                          for (var term
                                              in TermService.getTermsOfProgram(
                                                  program.programId)) {
                                            term.isSelected =
                                                program.isSelected;
                                            for (var course in CourseService
                                                .getCoursesOfTerm(
                                                    term.termId)) {
                                              course.isSelected =
                                                  term.isSelected;
                                              for (var assignment
                                                  in AssignmentService
                                                      .getAssignmentsOfCourse(
                                                          course.courseId)) {
                                                assignment.isSelected =
                                                    course.isSelected;
                                              }
                                              for (var classItem in ClassService
                                                  .getClassesOfCourse(
                                                      course.courseId)) {
                                                classItem.isSelected =
                                                    course.isSelected;
                                              }
                                            }
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(child: Text(program.name)),
                                  ],
                                ),
                                children: TermService.getTermsOfProgram(
                                        program.programId)
                                    .map((term) {
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Checkbox(
                                            value: term.isSelected,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                term.isSelected =
                                                    newValue ?? false;
                                                for (var course in CourseService
                                                    .getCoursesOfTerm(
                                                        term.termId)) {
                                                  course.isSelected =
                                                      term.isSelected;
                                                  for (var assignment
                                                      in AssignmentService
                                                          .getAssignmentsOfCourse(
                                                              course
                                                                  .courseId)) {
                                                    assignment.isSelected =
                                                        course.isSelected;
                                                  }
                                                  for (var classItem
                                                      in ClassService
                                                          .getClassesOfCourse(
                                                              course
                                                                  .courseId)) {
                                                    classItem.isSelected =
                                                        course.isSelected;
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                          Expanded(
                                              child: Text(
                                                  'Term ${TermService.getTermNumber(term)}')),
                                        ],
                                      ),
                                      children: CourseService.getCoursesOfTerm(
                                              term.termId)
                                          .map((course) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: ExpansionTile(
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Checkbox(
                                                    value: course.isSelected,
                                                    onChanged:
                                                        (bool? newValue) {
                                                      setState(() {
                                                        course.isSelected =
                                                            newValue ?? false;
                                                        for (var assignment
                                                            in AssignmentService
                                                                .getAssignmentsOfCourse(
                                                                    course
                                                                        .courseId)) {
                                                          assignment
                                                                  .isSelected =
                                                              course.isSelected;
                                                        }
                                                        for (var classItem
                                                            in ClassService
                                                                .getClassesOfCourse(
                                                                    course
                                                                        .courseId)) {
                                                          classItem.isSelected =
                                                              course.isSelected;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Expanded(
                                                      child: Text(course.code)),
                                                ],
                                              ),
                                              children: [
                                                if (AssignmentService
                                                        .getAssignmentsOfCourse(
                                                            course.courseId)
                                                    .isNotEmpty)
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 24.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Checkbox(
                                                            value: AssignmentService
                                                                    .getAssignmentsOfCourse(
                                                                        course
                                                                            .courseId)
                                                                .every((assignment) =>
                                                                    assignment
                                                                        .isSelected),
                                                            onChanged: (bool?
                                                                newValue) {
                                                              setState(() {
                                                                for (var assignment
                                                                    in AssignmentService
                                                                        .getAssignmentsOfCourse(
                                                                            course.courseId)) {
                                                                  assignment
                                                                          .isSelected =
                                                                      newValue ??
                                                                          false;
                                                                }
                                                              });
                                                            },
                                                          ),
                                                          Text('Assignments'),
                                                        ],
                                                      )),
                                                if (ClassService
                                                        .getClassesOfCourse(
                                                            course.courseId)
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Checkbox(
                                                          value: ClassService
                                                                  .getClassesOfCourse(
                                                                      course
                                                                          .courseId)
                                                              .every((classItem) =>
                                                                  classItem
                                                                      .isSelected),
                                                          onChanged:
                                                              (bool? newValue) {
                                                            setState(() {
                                                              for (var classItem
                                                                  in ClassService
                                                                      .getClassesOfCourse(
                                                                          course
                                                                              .courseId)) {
                                                                classItem
                                                                        .isSelected =
                                                                    newValue ??
                                                                        false;
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        Text('Classes'),
                                                      ],
                                                    ),
                                                  )
                                              ]),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: FilledButton(
                onPressed: () async {
                  // Get all checked classes
                  final checkedClasses = ClassService.getAllClasses()
                      .where((element) => element.isSelected == true)
                      .toList();

                  // Add classes to events
                  var eventsClasses =
                      AddClasses(checkedClasses, _currentLocation!);
                  if (!eventsClasses.isEmpty) {
                    for (var event in eventsClasses) {
                      events.add(event);
                    }
                  }

                  // Get all checked assignments
                  final checkedAssignments =
                      AssignmentService.getAllAssignments()
                          .where((element) => element.isSelected == true)
                          .toList();

                  // Add assignments to events
                  var eventsAssignments =
                      AddAssignments(checkedAssignments, _currentLocation!);
                  if (!eventsAssignments.isEmpty) {
                    for (var event in eventsAssignments) {
                      events.add(event);
                    }
                  }

                  if (events.isNotEmpty) {
                    bool success = await AddToCalendar(events);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(success ? 'Success' : 'Failure'),
                          content: Text(success
                              ? 'The event was created successfully.'
                              : 'Failed to create the event.'),
                          actions: <Widget>[
                            FilledButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('No Events Selected'),
                          content: Text(
                              'Please select at least one class or assignment to add to the calendar.'),
                          actions: <Widget>[
                            FilledButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }

                  eventsClasses.clear();
                  eventsAssignments.clear();
                  events.clear();
                },
                child: Text('Add'),
              ),
            ),
          ],
        )));
  }
}
