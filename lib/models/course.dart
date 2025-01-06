import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../shared/get_diretory.dart';
import 'dart:io';
import 'selectable.dart';
import 'term.dart';
import 'assignment.dart';
import 'class.dart';
import 'program.dart';
import 'package:collection/collection.dart';

class Course extends Selectable {
  int courseId;
  int termId;
  String code;
  String name;
  String professor;
  double? minimumGrade;

  Course({
    required this.courseId,
    required this.code,
    required this.name,
    required this.professor,
    required this.termId,
    this.minimumGrade,
  });

  // Convert a Course to JSON
  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'termId': termId,
      'code': code,
      'name': name,
      'professor': professor,
      'minimumGrade': minimumGrade,
    };
  }

  // Create a Course from JSON
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId'],
      code: json['code'],
      name: json['name'],
      professor: json['professor'],
      termId: json['termId'],
      minimumGrade: json['minimumGrade'],
    );
  }

  @override
  String toString() {
    return 'Course{courseId: $courseId, termId: $termId, code: $code, name: $name, professor: $professor, minimumGrade: $minimumGrade}';
  }
}

class CourseService {
  static List<Course> courses = [];

  // Add a course
  static void addCourse(Course course) {
    if (courses.any((c) => c.courseId == course.courseId)) {
      debugPrint("Course with ID ${course.courseId} already exists.");
      return;
    }
    courses.add(course);
    saveCoursesToFile();

    debugPrint('Course added: ${course.toString()}');
  }

  // Delete a course
  static void deleteCourse(int courseId) {
    int index = courses.indexWhere((course) => course.courseId == courseId);
    if (index != -1) {
      Course course = courses[index];

      // Delete all assignments of the course
      AssignmentService.getAssignmentsOfCourse(course.courseId)
          .forEach((assignment) {
        AssignmentService.deleteAssignment(assignment.assignmentId);
      });

      // Delete all classes of the course
      ClassService.getClassesOfCourse(course.courseId).forEach((classItem) {
        ClassService.deleteClass(classItem.classId);
      });

      courses.removeAt(index);

      saveCoursesToFile();

      debugPrint('Course deleted: ${course.toString()}');
    }
  }

  // Edit a course
  static void editCourse(Course updatedCourse) {
    int index = courses
        .indexWhere((course) => course.courseId == updatedCourse.courseId);
    if (index != -1) {
      courses[index] = updatedCourse;
    }

    saveCoursesToFile();

    debugPrint('Course edited: ${updatedCourse.toString()}');
  }

  // Method to find a course by its ID
  static Course? findCourseById(int id) {
    return courses.firstWhereOrNull((course) => course.courseId == id);
  }

  // Get all courses
  static List<Course> getAllCourses() {
    return List.unmodifiable(courses);
  }

  // Get courses of a specific term
  static List<Course> getCoursesOfTerm(int termId) {
    return courses.where((course) => course.termId == termId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Get finished courses of a program
  static List<Course> getFinishedCoursesOfProgram(Program program) {
    return TermService.getTermsOfProgram(program.programId).expand((term) {
      return getCoursesOfTerm(term.termId).where((course) {
        bool isTermFinished = term.endDate.isBefore(DateTime.now());
        return isTermFinished;
      });
    }).toList();
  }

  // Convert all courses to JSON
  static String getcoursesJson() {
    List<Map<String, dynamic>> courseMaps =
        courses.map((course) => course.toJson()).toList();
    return jsonEncode(courseMaps);
  }

  // Load courses from JSON string
  static void loadcoursesFromJson(String jsonData) {
    List<dynamic> jsonList = jsonDecode(jsonData);
    courses = jsonList.map((json) => Course.fromJson(json)).toList();
  }

  // Load courses from a file
  static Future<void> loadCoursesFromFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/courses.json');

      // Check if the file exists
      if (await file.exists()) {
        String jsonData = await file.readAsString();
        loadcoursesFromJson(jsonData);
      } else {
        debugPrint("Courses file not found. Initializing with an empty list.");
      }
    } catch (e) {
      // Handle the case where the file does not exist
      debugPrint("Error reading courses file: $e");
    }
  }

  // Save courses to a file
  static Future<void> saveCoursesToFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/courses.json');

      // Get JSON data from the institutions
      String jsonData = getcoursesJson();

      // Write the JSON data to the file
      await file.writeAsString(jsonData);
    } catch (e) {
      debugPrint("Error writing courses to file: $e");
    }
  }
}
