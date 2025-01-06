import '../models/assignment.dart';
import '../models/convertions.dart';
import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/course.dart';
import '../shared/colors.dart';
import 'assignments_screen.dart';

class GradesScreen extends StatefulWidget {
  GradesScreen({Key? key}) : super(key: key);

  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final int $alpha = 0x03B1;

  // Navigate to assignments screen
  void ViewDetails(Course course, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignmentsScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grades', style: TextStyle(color: MyColors.onSurface)),
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount: ProgramService.getAllPrograms().length,
          itemBuilder: (context, index) {
            Program program = ProgramService.getAllPrograms()[index];

            return Column(
              children: [
                // Expandable Courses list under the program
                ExpansionTile(
                  title: Text(
                      "${program.name} (${CourseService.getFinishedCoursesOfProgram(program).length})"),
                  children: [
                    // Display Courses List under the program
                    for (var course
                        in CourseService.getFinishedCoursesOfProgram(program))
                      ListTile(
                        title: Text("${course.code} - ${course.name}",
                            style: Theme.of(context).textTheme.bodyMedium),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "#: ${AssignmentService.getCourseGrade(course).toStringAsFixed(0)}%",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '${String.fromCharCode($alpha)}: ${Convertions.gradeToAlpha(AssignmentService.getCourseGrade(course))}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'GPA: ${Convertions.gradeToGpa(AssignmentService.getCourseGrade(course))}',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          ],
                        ),
                        trailing: IconButton(
                            icon: Icon(Icons.description),
                            onPressed: () => ViewDetails(course, context)),
                      ),
                    Text(
                        'Program #: ${ProgramService.getAverageGrade(program).toStringAsFixed(0)}%'),
                    Text(
                        'Program GPA: ${ProgramService.getAverageGPA(program).toStringAsFixed(2)}'),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
