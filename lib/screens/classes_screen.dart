import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../models/course.dart';
import '../models/class.dart';
import '../models/convertions.dart';
import '../shared/pick_time.dart';
import '../shared/dialog_message.dart';

class ClassesScreen extends StatefulWidget {
  final Course course;

  ClassesScreen({required this.course});

  @override
  _ClassesScreenState createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final TextEditingController _roomController = TextEditingController();
  bool isOnline = false; // This holds the checkbox state

  @override
  void dispose() {
    super.dispose();
  }

  // Method to handle checkbox state change inside dialog
  void updatedCheckboxValue(bool? value) {
    setState(() {
      isOnline = value!;
    });
  }

  // Method to generate the class form and show dialog
  Future<Class?> GenerateClassForm({int classId = 0}) async {
    Class? lesson;

    String? selectedDay;
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;
    bool tempIsOnline = isOnline; // Save the current state for the dialog

    if (classId != 0) {
      lesson = ClassService.findClassById(classId)!;

      _roomController.text = lesson.room ?? '';
      selectedDay = Convertions.getDayOfWeek(lesson.dayOfWeek);
      selectedStartTime = lesson.startTime;
      selectedEndTime = lesson.endTime;
      tempIsOnline = lesson.isOnline;
    }

    return showDialog<Class?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(classId != 0
              ? 'Edit Class Information'
              : 'Enter Class Information'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: _roomController,
                      decoration: InputDecoration(hintText: 'Classroom'),
                    ),
                  ),
                  // Day of Week Dropdown
                  DropdownButton<String>(
                    hint: Text('Select Day of the Week'),
                    value: selectedDay,
                    items: <String>[
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedDay = value;
                      });
                    },
                  ),
                  // Start Time Picker
                  FilledButton(
                    onPressed: () async {
                      selectedStartTime = await PickATime.SelectTime(
                          context, selectedStartTime);
                      setState(() {});
                    },
                    child: Text(
                      selectedStartTime == null
                          ? 'Select Start Time'
                          : 'Start Time: ${selectedStartTime!.format(context)}',
                    ),
                  ),
                  // End Time Picker
                  FilledButton(
                    onPressed: () async {
                      selectedEndTime =
                          await PickATime.SelectTime(context, selectedEndTime);
                      setState(() {});
                    },
                    child: Text(
                      selectedEndTime == null
                          ? 'Select End Time'
                          : 'End Time: ${selectedEndTime!.format(context)}',
                    ),
                  ),
                  // Checkbox for Online status
                  CheckboxListTile(
                    value: tempIsOnline,
                    onChanged: (bool? value) {
                      setState(() {
                        tempIsOnline = value ?? false;
                      });
                    },
                    title: Text('Online'),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                _roomController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                String? classRoom = _roomController.text;
                if (selectedStartTime != null &&
                    selectedEndTime != null &&
                    selectedDay != null &&
                    (selectedEndTime!.hour > selectedStartTime!.hour ||
                        (selectedEndTime!.hour == selectedStartTime!.hour &&
                            selectedEndTime!.minute >
                                selectedStartTime!.minute))) {
                  lesson = Class(
                    classId: classId != 0
                        ? classId
                        : DateTime.now().millisecondsSinceEpoch,
                    room: classRoom,
                    courseId: widget.course.courseId,
                    dayOfWeek: Convertions.getDayOfWeekNumber(selectedDay!),
                    startTime: selectedStartTime!,
                    endTime: selectedEndTime!,
                    isOnline: tempIsOnline,
                  );

                  if (ClassService.hasOverlap(lesson!)) {
                    ShowMessageDialog(
                        'Error',
                        'This class overlaps with another class in this term.',
                        context);
                  } else {
                    _roomController.clear();

                    Navigator.of(context).pop(lesson);
                  }
                } else {
                  ShowMessageDialog(
                      'Error',
                      'Please select day of the week, start and end time (start time should be before end time).',
                      context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to add a class
  void AddClass() async {
    Class? lesson = await GenerateClassForm();

    if (lesson != null) {
      setState(() {
        ClassService.addClass(lesson);
      });
    }
  }

  // Method to delete a class
  void DeleteClass(Class lesson) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this class?'),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  ClassService.deleteClass(lesson.classId);
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Method to edit a class
  void EditClass(Class lesson) async {
    Class? updatedLesson = await GenerateClassForm(classId: lesson.classId);

    if (updatedLesson != null) {
      setState(() {
        ClassService.editClass(updatedLesson);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classes', style: TextStyle(color: MyColors.onSurface)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: MyColors.onSurface,
            onPressed: () => AddClass(),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: MyColors.onSurface,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount:
              ClassService.getClassesOfCourse(widget.course.courseId).length,
          itemBuilder: (context, index) {
            Class lesson =
                ClassService.getClassesOfCourse(widget.course.courseId)[index];

            return Column(
              children: [
                ListTile(
                  title: Text("${Convertions.getDayOfWeek(lesson.dayOfWeek)}"),
                  subtitle: Text(
                      '${lesson.startTime.format(context)} - ${lesson.endTime.format(context)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => EditClass(lesson),
                      ),
                      // Delete button
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => DeleteClass(lesson),
                      ),
                    ],
                  ),
                ),
                Divider(),
              ],
            );
          },
        ),
      ),
    );
  }
}
