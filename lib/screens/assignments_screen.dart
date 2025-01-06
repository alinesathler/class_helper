import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../models/course.dart';
import '../models/assignment.dart';
import '../shared/pick_date.dart';
import 'calculator_screen.dart';
import '../shared/dialog_message.dart';

class AssignmentsScreen extends StatefulWidget {
  final Course course;

  AssignmentsScreen({required this.course});

  @override
  _AssignmentsScreenState createState() =>
      _AssignmentsScreenState(course: course);
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final Course course;

  final TextEditingController _assignmentNameController =
      TextEditingController();
  final TextEditingController _assignmentPointsController =
      TextEditingController();
  final TextEditingController _assignmentWeightController =
      TextEditingController();
  final TextEditingController _assignmentPointsEarnedController =
      TextEditingController();

  _AssignmentsScreenState({required this.course});

  @override
  void dispose() {
    _assignmentNameController.dispose();
    _assignmentPointsController.dispose();
    _assignmentWeightController.dispose();
    _assignmentPointsEarnedController.dispose();
    super.dispose();
  }

  // Method to generate assignment form
  Future<Assignment?> GenerateAssignmentForm({int assignmentId = 0}) async {
    Assignment? assignment;
    DateTime? selectedDueDate;

    if (assignmentId != 0) {
      assignment = AssignmentService.findAssignmentById(assignmentId)!;

      _assignmentNameController.text = assignment.name;
      _assignmentPointsController.text = assignment.points.toString();
      _assignmentWeightController.text = assignment.weight.toString();
      _assignmentPointsEarnedController.text = assignment.pointsEarned != null
          ? assignment.pointsEarned.toString()
          : '';
      selectedDueDate = assignment.dueDate;
    }

    return showDialog<Assignment?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(assignmentId != 0 ? 'Edit Assignment' : 'Enter Assignment'),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: TextField(
                    controller: _assignmentNameController,
                    decoration: InputDecoration(hintText: 'Assignment name'),
                  ),
                ),
                Container(
                  child: TextField(
                    controller: _assignmentPointsController,
                    decoration: InputDecoration(hintText: 'Points'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  child: TextField(
                    controller: _assignmentWeightController,
                    decoration: InputDecoration(hintText: 'Weight'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  child: TextField(
                    controller: _assignmentPointsEarnedController,
                    decoration: InputDecoration(hintText: 'Points Earned'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    selectedDueDate =
                        await PickADate.SelectDate(context, selectedDueDate);
                    if (selectedDueDate != null) {
                      setState(() {});
                    }
                  },
                  child: Text(
                    selectedDueDate == null
                        ? 'Select Due Date'
                        : 'Due Date: ${selectedDueDate!.toLocal().toString().split(' ')[0]}',
                  ),
                ),
              ],
            );
          }),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();

                _assignmentNameController.text = '';
                _assignmentPointsController.text = '';
                _assignmentWeightController.text = '';
                _assignmentPointsEarnedController.text = '';
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                String assignmentName = _assignmentNameController.text;
                double? points =
                    double.tryParse(_assignmentPointsController.text);
                double? weight =
                    double.tryParse(_assignmentWeightController.text);
                double? pointsEarned =
                    double.tryParse(_assignmentPointsEarnedController.text);

                if (assignmentName.isNotEmpty && selectedDueDate != null) {
                  points ??= 0;
                  weight ??= 0;

                  setState(() {
                    assignment = Assignment(
                        assignmentId: assignmentId != 0
                            ? assignmentId
                            : DateTime.now().millisecondsSinceEpoch,
                        name: assignmentName,
                        points: points!,
                        weight: weight!,
                        pointsEarned: pointsEarned,
                        courseId: course.courseId,
                        dueDate: selectedDueDate!);
                  });

                  _assignmentNameController.text = '';
                  _assignmentPointsController.text = '';
                  _assignmentWeightController.text = '';
                  _assignmentPointsEarnedController.text = '';

                  Navigator.of(context).pop(assignment);
                } else {
                  ShowMessageDialog('Error',
                      'Please enter valid assignment information.', context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to add an assignment
  Future<void> AddAssignment() async {
    Assignment? newAssignment = await GenerateAssignmentForm();

    if (newAssignment != null) {
      setState(() {
        AssignmentService.addAssignment(newAssignment);
      });
    }
  }

  // Method to delete an assignment
  void DeleteAssignment(Assignment assignment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this assignment?'),
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
                  AssignmentService.deleteAssignment(assignment.assignmentId);
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

  // Method to edit an assignment
  Future<void> EditAssignment(Assignment assignment) async {
    Assignment? updatedAssignment =
        await GenerateAssignmentForm(assignmentId: assignment.assignmentId);

    if (updatedAssignment != null) {
      setState(() {
        assignment.name = updatedAssignment.name;
        assignment.points = updatedAssignment.points;
        assignment.weight = updatedAssignment.weight;
        assignment.pointsEarned = updatedAssignment.pointsEarned;
        assignment.dueDate = updatedAssignment.dueDate;
      });
    }
  }

  // Navigate to calculate grades screen
  void CalculateGrade(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculateScreen(course: course),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments', style: TextStyle(color: MyColors.onSurface)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: MyColors.onSurface,
            onPressed: () => AddAssignment(),
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
                      "Grade: ${AssignmentService.getCourseGrade(course).toStringAsFixed(2)}%",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.calculate),
                  onPressed: () => CalculateGrade(course),
                ),
              ],
            ),
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

                return Column(
                  children: [
                    ListTile(
                      title: Text("${assignment.name}"),
                      subtitle: Text(
                        'Points: ${assignment.pointsEarned ?? 0}/${assignment.points.toStringAsFixed(2)}\n'
                        'Weight: ${AssignmentService.getWeightEarned(assignment).toStringAsFixed(2)}/${assignment.weight.toStringAsFixed(2)}\n'
                        'Grade: ${AssignmentService.getGradeEarned(assignment).toStringAsFixed(2)}%',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => EditAssignment(assignment),
                          ),
                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => DeleteAssignment(assignment),
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
        ],
      ),
    );
  }
}
