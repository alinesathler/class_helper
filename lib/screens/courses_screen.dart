import '../models/assignment.dart';
import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../models/term.dart';
import '../models/course.dart';
import 'assignments_screen.dart';
import '../shared/dialog_message.dart';
import 'classes_screen.dart';

class CoursesScreen extends StatefulWidget {
  final Term term;
  final int termNumber;

  CoursesScreen({required this.term, required this.termNumber});

  @override
  _CoursesScreenState createState() =>
      _CoursesScreenState(term: term, termNumber: termNumber);
}

class _CoursesScreenState extends State<CoursesScreen> {
  final Term term;
  final int termNumber;

  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseProfessorController =
      TextEditingController();
  final TextEditingController _courseMinGradeController =
      TextEditingController();

  _CoursesScreenState({required this.term, required this.termNumber});

  @override
  void dispose() {
    _courseCodeController.dispose();
    _courseNameController.dispose();
    _courseProfessorController.dispose();
    _courseMinGradeController.dispose();

    super.dispose();
  }

  // Method to generate course form
  Future<Course?> GenerateCourseForm({int courseId = 0}) async {
    Course? course;

    if (courseId != 0) {
      course = CourseService.findCourseById(courseId)!;

      _courseCodeController.text = course.code;
      _courseNameController.text = course.name;
      _courseProfessorController.text = course.professor;
      _courseMinGradeController.text = course.minimumGrade != null
          ? course.minimumGrade!.toStringAsFixed(2)
          : '';
    }

    return showDialog<Course?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(courseId != 0
              ? 'Edit Course Information'
              : 'Enter Course Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: TextField(
                  controller: _courseCodeController,
                  decoration: InputDecoration(hintText: 'Course code'),
                ),
              ),
              Container(
                child: TextField(
                  controller: _courseNameController,
                  decoration: InputDecoration(hintText: 'Course name'),
                ),
              ),
              Container(
                child: TextField(
                  controller: _courseProfessorController,
                  decoration: InputDecoration(hintText: 'Course professor'),
                ),
              ),
              Container(
                child: TextField(
                  controller: _courseMinGradeController,
                  decoration: InputDecoration(hintText: 'Minimum grade'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _courseCodeController.text = '';
                _courseNameController.text = '';
                _courseProfessorController.text = '';
                _courseMinGradeController.text = '';
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                String courseCode = _courseCodeController.text;
                String courseName = _courseNameController.text;
                String courseProfessor = _courseProfessorController.text;
                double? courseMinGrade =
                    _courseMinGradeController.text.isNotEmpty
                        ? double.parse(_courseMinGradeController.text)
                        : null;

                if (courseCode.isNotEmpty &&
                    courseName.isNotEmpty &&
                    courseProfessor.isNotEmpty) {
                  setState(() {
                    course = Course(
                        courseId: courseId != 0
                            ? courseId
                            : DateTime.now().millisecondsSinceEpoch,
                        code: courseCode,
                        name: courseName,
                        professor: courseProfessor,
                        termId: term.termId,
                        minimumGrade: courseMinGrade);
                  });

                  _courseCodeController.text = '';
                  _courseNameController.text = '';
                  _courseProfessorController.text = '';

                  Navigator.of(context).pop(course);
                } else {
                  ShowMessageDialog('Error',
                      'Please enter valid course information.', context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to add a course
  Future<void> AddCourse() async {
    Course? newCourse = await GenerateCourseForm();

    if (newCourse != null) {
      setState(() {
        CourseService.addCourse(newCourse);
      });
    }
  }

  // Method to delete a course
  void DeleteCourse(Course course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete this course and all its data (This action cannot be reversed)?'),
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
                  CourseService.deleteCourse(course.courseId);
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

  // Method to edit a course
  Future<void> EditCourse(Course course) async {
    Course? updatedCourse = await GenerateCourseForm(courseId: course.courseId);

    if (updatedCourse != null) {
      setState(() {
        CourseService.editCourse(updatedCourse);
      });
    }
  }

  // Navigate to assignments screen
  void ViewDetails(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentsScreen(course: course),
      ),
    );
  }

  // Navigate to classes screen
  void ViewClasses(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassesScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses', style: TextStyle(color: MyColors.onSurface)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: MyColors.onSurface,
            onPressed: () => AddCourse(),
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
          itemCount: CourseService.getCoursesOfTerm(term.termId).length,
          itemBuilder: (context, index) {
            Course course = CourseService.getCoursesOfTerm(term.termId)[index];

            bool? isApproved = AssignmentService.isStudentApproved(course);

            return Column(
              children: [
                ListTile(
                  title: Text("${course.code}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${course.name}'),
                      Text('${course.professor}'),
                      Text(
                        isApproved == null
                            ? ''
                            : isApproved
                                ? 'Approved'
                                : 'Not approved',
                        style: TextStyle(
                          color: isApproved == null
                              ? MyColors.onSecondary
                              : isApproved
                                  ? MyColors.successGreen
                                  : MyColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                  trailing: FittedBox(
                    fit: BoxFit.fill,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.description),
                          onPressed: () => ViewDetails(course),
                        ),
                        IconButton(
                          icon: Icon(Icons.date_range),
                          onPressed: () => ViewClasses(course),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => EditCourse(course),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => DeleteCourse(course),
                        ),
                      ],
                    ),
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
