import 'dart:convert';
import 'package:flutter/material.dart';
import '../shared/get_diretory.dart';
import 'dart:io';
import 'course.dart';
import 'selectable.dart';
import 'term.dart';
import 'package:collection/collection.dart';

class Assignment extends Selectable {
  int assignmentId;
  int courseId;
  String name;
  DateTime dueDate;
  double points;
  double weight;
  double? pointsEarned;

  Assignment({
    required this.assignmentId,
    required this.courseId,
    required this.name,
    required this.dueDate,
    this.points = 0,
    this.weight = 0,
    this.pointsEarned,
  });

  // Convert an Assignment to JSON
  Map<String, dynamic> toJson() {
    return {
      'assignmentId': assignmentId,
      'courseId': courseId,
      'name': name,
      'dueDate': dueDate.toIso8601String(),
      'points': points,
      'weight': weight,
      'pointsEarned': pointsEarned,
    };
  }

  // Create an Assignment from JSON
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignmentId: json['assignmentId'],
      courseId: json['courseId'],
      name: json['name'],
      dueDate: DateTime.parse(json['dueDate']),
      points: json['points'],
      weight: json['weight'],
      pointsEarned: json['pointsEarned'],
    );
  }

  @override
  String toString() {
    return 'Assignment{assignmentId: $assignmentId, courseId: $courseId, name: $name, dueDate: $dueDate, points: $points, weight: $weight, pointsEarned: $pointsEarned}';
  }
}

class AssignmentService {
  static List<Assignment> assignments = [];

  // Add an assignment
  static void addAssignment(Assignment assignment) {
    if (assignments.any((a) => a.assignmentId == assignment.assignmentId)) {
      debugPrint(
          'Assignment with ID ${assignment.assignmentId} already exists.');
      return;
    }
    assignments.add(assignment);
    saveAssignmentsToFile();
    debugPrint("Assignment added: " + assignment.toString());
  }

  // Delete an assignment
  static void deleteAssignment(int assignmentId) {
    int index = assignments.indexWhere((a) => a.assignmentId == assignmentId);
    if (index != -1) {
      assignments.removeAt(index);
      saveAssignmentsToFile();

      debugPrint("Assignment deleted: " + assignmentId.toString());
    }
  }

  // Edit an assignment
  static void editAssignment(Assignment updatedAssignment) {
    int index = assignments
        .indexWhere((a) => a.assignmentId == updatedAssignment.assignmentId);
    if (index != -1) {
      assignments[index] = updatedAssignment;
      saveAssignmentsToFile();

      debugPrint("Assignment edited: " + updatedAssignment.toString());
    }
  }

  // Find an assignment by ID
  static Assignment? findAssignmentById(int assignmentId) {
    return assignments.firstWhereOrNull((a) => a.assignmentId == assignmentId);
  }

  // Get all assignments
  static List<Assignment> getAllAssignments() {
    return List.unmodifiable(assignments);
  }

  // Get assignments of a specific course
  static List<Assignment> getAssignmentsOfCourse(int courseId) {
    return assignments.where((a) => a.courseId == courseId).toList();
  }

  // Method to get the weight earned of an assignment
  static double getWeightEarned(Assignment assignment) {
    return (assignment.points > 0 && assignment.pointsEarned != null)
        ? (assignment.pointsEarned! / assignment.points) * assignment.weight
        : 0;
  }

  // Method to get the grade earned of an assignment
  static double getGradeEarned(Assignment assignment) {
    return (assignment.points > 0 && assignment.pointsEarned != null)
        ? (assignment.pointsEarned! / assignment.points) * 100
        : 0;
  }

  // Method to get the grade of a course
  static double getCourseGrade(Course course) {
    double totalWeight = getCourseWeight(course);
    double totalWeightEarned = getCourseWeightEarned(course);

    return totalWeight == 0 ? 0 : (totalWeightEarned / totalWeight) * 100;
  }

  // Method to get the weight of a course
  static double getCourseWeight(Course course) {
    return getAssignmentsOfCourse(course.courseId).fold(
        0.0, (totalWeight, assignment) => totalWeight + assignment.weight);
  }

  // Method to get the weight earned of a course
  static double getCourseWeightEarned(Course course) {
    return getAssignmentsOfCourse(course.courseId).fold(
        0.0,
        (totalWeightEarned, assignment) =>
            totalWeightEarned + getWeightEarned(assignment));
  }

  // Method to get the maximum grade of a course
  static double getCourseMaximumGrade(Course course) {
    List<Assignment> assignments = getAssignmentsOfCourse(course.courseId);

    if (assignments.isEmpty) return 0;

    double totalWeight = getCourseWeight(course);
    double totalWeightEarned = assignments.fold(0.0, (total, assignment) {
      double maxWeightEarned = assignment.pointsEarned == null
          ? assignment.weight
          : getWeightEarned(assignment);
      return total + maxWeightEarned;
    });

    return (totalWeightEarned / totalWeight) * 100;
  }

  // Method to get the simulated grade of a course
  static double getSimulatedCourseGrade(
      Course course, Map<int, TextEditingController> pointsEarnedControllers) {
    List<Assignment> assignments = getAssignmentsOfCourse(course.courseId);

    if (assignments.isEmpty) return 0;

    return assignments.fold(0.0, (simulatedFinalGrade, assignment) {
      double simulatedPoints = double.tryParse(
              pointsEarnedControllers[assignment.assignmentId]?.text ?? '0') ??
          0;

      return simulatedFinalGrade +
          (simulatedPoints * assignment.weight / assignment.points);
    });
  }

  // Method to check if a student is approved in a course
  static bool? isStudentApproved(Course course) {
    double courseGrade = getCourseGrade(course);
    DateTime endTermDate =
        TermService.findTermById(course.termId)?.endDate ?? DateTime.now();

    if (course.minimumGrade == null) return null;

    if (courseGrade >= course.minimumGrade!) return true;

    return courseGrade < course.minimumGrade! &&
            DateTime.now().isAfter(endTermDate)
        ? false
        : null;
  }

  // Convert all assignments to JSON
  static String getAssignmentsJson() {
    return jsonEncode(assignments.map((a) => a.toJson()).toList());
  }

  // Load assignments from JSON string
  static void loadAssignmentsFromJson(String jsonData) {
    List<dynamic> jsonList = jsonDecode(jsonData);
    assignments = jsonList.map((json) => Assignment.fromJson(json)).toList();
  }

  // Load assignments from a file
  static Future<void> loadAssignmentsFromFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/assignments.json');
      if (await file.exists()) {
        String jsonData = await file.readAsString();
        loadAssignmentsFromJson(jsonData);
      } else {
        debugPrint(
            "Assignments file not found. Initializing with an empty list.");
      }
    } catch (e) {
      debugPrint("Error reading assignments file: $e");
    }
  }

  // Save assignments to a file
  static Future<void> saveAssignmentsToFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/assignments.json');
      String jsonData = getAssignmentsJson();
      await file.writeAsString(jsonData);
    } catch (e) {
      debugPrint("Error writing assignments to file: $e");
    }
  }
}
