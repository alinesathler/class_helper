import 'dart:convert';
import '../shared/get_diretory.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'course.dart';
import 'selectable.dart';
import 'package:collection/collection.dart';

class Class extends Selectable {
  int classId;
  int courseId;
  int dayOfWeek;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isOnline;
  String? room;

  Class({
    required this.classId,
    required this.courseId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isOnline,
    this.room,
  });

  // Convert a Class to JSON
  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'courseId': courseId,
      'dayOfWeek': dayOfWeek,
      'startTime': _timeToJson(startTime),
      'endTime': _timeToJson(endTime),
      'isOnline': isOnline,
      'room': room,
    };
  }

  // Create a Class from JSON
  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      classId: json['classId'],
      courseId: json['courseId'],
      dayOfWeek: json['dayOfWeek'],
      startTime: _timeFromJson(json['startTime']),
      endTime: _timeFromJson(json['endTime']),
      isOnline: json['isOnline'],
      room: json['room'],
    );
  }

  @override
  String toString() {
    return 'Class{classId: $classId, courseId: $courseId, dayOfWeek: $dayOfWeek, startTime: $startTime, endTime: $endTime, isOnline: $isOnline, room: $room}';
  }

  // Helper methods for TimeOfDay serialization
  static String _timeToJson(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  static TimeOfDay _timeFromJson(String time) {
    final parts = time.split(':').map(int.parse).toList();
    return TimeOfDay(hour: parts[0], minute: parts[1]);
  }
}

class ClassService {
  static List<Class> classes = [];

  // Add a class
  static void addClass(Class classItem) {
    if (classes.any((c) => c.classId == classItem.classId)) {
      print('Class with ID ${classItem.classId} already exists.');
      return;
    }
    classes.add(classItem);
    saveClassesToFile();

    debugPrint('Class added: ${classItem.toString()}');
  }

  // Delete a class
  static void deleteClass(int classId) {
    int index = classes.indexWhere((c) => c.classId == classId);
    if (index != -1) {
      classes.removeAt(index);
      saveClassesToFile();

      debugPrint('Class deleted: $classId');
    }
  }

  // Edit a class
  static void editClass(Class updatedClass) {
    int index = classes.indexWhere((c) => c.classId == updatedClass.classId);
    if (index != -1) {
      classes[index] = updatedClass;
      saveClassesToFile();

      debugPrint('Class edited: ${updatedClass.toString()}');
    }
  }

  // Find a class by ID
  static Class? findClassById(int classId) {
    return classes.firstWhereOrNull((c) => c.classId == classId);
  }

  // Get all classes
  static List<Class> getAllClasses() {
    return List.unmodifiable(classes);
  }

  // Get classes of a specific course
  static List<Class> getClassesOfCourse(int courseId) {
    return classes.where((c) => c.courseId == courseId).toList();
  }

  // Calculate total course credits
  static int getCourseCredits(Course course) {
    return getClassesOfCourse(course.courseId).fold(0,
        (totalCredits, classItem) {
      final startMinutes =
          classItem.startTime.hour * 60 + classItem.startTime.minute;
      final endMinutes = classItem.endTime.hour * 60 + classItem.endTime.minute;
      return totalCredits + (endMinutes - startMinutes) ~/ 60;
    });
  }

  // Check if a new class overlaps with existing classes
  static bool hasOverlap(Class newClass) {
    int termId = CourseService.findCourseById(newClass.courseId)?.termId ?? -1;

    // Find classes on the same day and within the same term
    List<Class> sameDayClasses = classes.where((c) {
      int existingClassTermId =
          CourseService.findCourseById(c.courseId)?.termId ?? -1;
      return c.dayOfWeek == newClass.dayOfWeek && existingClassTermId == termId;
    }).toList();

    for (var existingClass in sameDayClasses) {
      // Check if time ranges overlap
      if (!(newClass.endTime.hour < existingClass.startTime.hour ||
          (newClass.endTime.hour == existingClass.startTime.hour &&
              newClass.endTime.minute <= existingClass.startTime.minute) ||
          newClass.startTime.hour > existingClass.endTime.hour ||
          (newClass.startTime.hour == existingClass.endTime.hour &&
              newClass.startTime.minute >= existingClass.endTime.minute))) {
        return true;
      }
    }

    return false;
  }

  // Convert all classes to JSON
  static String getClassesJson() {
    return jsonEncode(classes.map((c) => c.toJson()).toList());
  }

  // Load classes from JSON string
  static void loadClassesFromJson(String jsonData) {
    List<dynamic> jsonList = jsonDecode(jsonData);
    classes = jsonList.map((json) => Class.fromJson(json)).toList();
  }

  // Load classes from a file
  static Future<void> loadClassesFromFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/classes.json');
      if (await file.exists()) {
        String jsonData = await file.readAsString();
        loadClassesFromJson(jsonData);
      } else {
        debugPrint("Classes file not found. Initializing with an empty list.");
      }
    } catch (e) {
      debugPrint("Error reading classes file: $e");
    }
  }

  // Save classes to a file
  static Future<void> saveClassesToFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/classes.json');
      String jsonData = getClassesJson();
      await file.writeAsString(jsonData);
    } catch (e) {
      debugPrint("Error writing classes to file: $e");
    }
  }
}
