import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../shared/colors.dart';

class CalculateScreen extends StatefulWidget {
  final Course course;

  CalculateScreen({required this.course});

  @override
  _CalculateScreenState createState() => _CalculateScreenState(course: course);
}

class _CalculateScreenState extends State<CalculateScreen> {
  final Course course;

  Map<int, TextEditingController> _pointsEarnedControllers = {};

  _CalculateScreenState({required this.course});

  @override
  void dispose() {
    for (var controller in _pointsEarnedControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each assignment
    for (var assignment
        in AssignmentService.getAssignmentsOfCourse(course.courseId)) {
      _pointsEarnedControllers[assignment.assignmentId] = TextEditingController(
          text: assignment.pointsEarned?.toString() ?? '');
    }
  }

  // Method to reset an assignment grade
  void ResetGrade(Assignment assignment) {
    setState(() {
      _pointsEarnedControllers[assignment.assignmentId]?.text =
          assignment.pointsEarned?.toString() ?? '';
    });
  }

  // Method to simulate grade
  void SimulateGrade(Course course) {
    double simulatedGrade = AssignmentService.getSimulatedCourseGrade(
        course, _pointsEarnedControllers);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Simulated Grade'),
          content: Text(
              'Your simulated grade is ${simulatedGrade.toStringAsFixed(2)}%.'),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Grades Calculator',
              style: TextStyle(color: MyColors.onSurface)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: MyColors.onSurface,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: MyColors.onPrimary,
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Weight: ${AssignmentService.getCourseWeightEarned(course).toStringAsFixed(2)}/${AssignmentService.getCourseWeight(course).toStringAsFixed(2)}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            "Minimum Grade: ${AssignmentService.getCourseGrade(course).toStringAsFixed(2)}%",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            "Maximum Grade: ${AssignmentService.getCourseMaximumGrade(course).toStringAsFixed(2)}%",
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        ]),
                  ]),
            ),
            Expanded(
              child: ListView.builder(
                itemCount:
                    AssignmentService.getAssignmentsOfCourse(course.courseId)
                        .length,
                itemBuilder: (context, index) {
                  Assignment assignment =
                      AssignmentService.getAssignmentsOfCourse(
                          course.courseId)[index];

                  TextEditingController _controller =
                      _pointsEarnedControllers[assignment.assignmentId]!;

                  return Column(
                    children: [
                      ListTile(
                        title: Text("${assignment.name}"),
                        subtitle: Container(
                          child: TextField(
                            controller: _controller,
                            decoration:
                                InputDecoration(hintText: 'Points Earned'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Reset Grade button
                            IconButton(
                              icon: Icon(Icons.restore),
                              onPressed: () => ResetGrade(assignment),
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
            Container(
              padding: EdgeInsets.all(10),
              child: FilledButton(
                onPressed: () => SimulateGrade(course),
                child: Text("Simulate"),
              ),
            ),
          ],
        ));
  }
}
