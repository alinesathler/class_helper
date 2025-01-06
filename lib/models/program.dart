import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../shared/get_diretory.dart';
import 'convertions.dart';
import 'course.dart';
import 'assignment.dart';
import 'class.dart';
import 'selectable.dart';
import 'term.dart';
import 'package:collection/collection.dart';

class Program extends Selectable {
  int programId;
  String name;
  int? institutionId;

  Program({
    required this.programId,
    required this.name,
    this.institutionId,
  });

  // Serialize Program to JSON
  Map<String, dynamic> toJson() {
    return {
      'programId': programId,
      'name': name,
      'institutionId': institutionId,
    };
  }

  // Deserialize JSON to a Program
  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      programId: json['programId'],
      name: json['name'],
      institutionId: json['institutionId'],
    );
  }

  @override
  String toString() {
    return 'Program{programId: $programId, name: $name, institutionId: $institutionId}';
  }
}

class ProgramService {
  static List<Program> programs = [];

  // Add a program
  static void addProgram(Program program) {
    if (programs.any((prog) => prog.programId == program.programId)) {
      debugPrint('Program with ID ${program.programId} already exists.');
      return;
    }
    programs.add(program);
    saveProgramsToFile();

    debugPrint('Program added: ${program.toString()}');
  }

  // Delete a program
  static void deleteProgram(int programId) {
    int index =
        programs.indexWhere((program) => program.programId == programId);
    if (index != -1) {
      for (var term
          in TermService.getTermsOfProgram(programs[index].programId)) {
        TermService.deleteTerm(term.termId);
      }

      programs.removeAt(index);

      saveProgramsToFile();

      debugPrint('Program deleted with ID $programId');
    }
  }

  // Edit a program
  static void editProgram(Program updatedProgram) {
    int index = programs
        .indexWhere((program) => program.programId == updatedProgram.programId);
    if (index != -1) {
      programs[index] = updatedProgram;

      debugPrint('Program edited: ${updatedProgram.toString()}');
    }
    saveProgramsToFile();
  }

  // Find a program by ID
  static Program? findProgramById(int programId) {
    return programs
        .firstWhereOrNull((program) => program.programId == programId);
  }

  // Get all programs
  static List<Program> getAllPrograms() {
    return List.unmodifiable(programs);
  }

  // Get programs of a specific institution
  static List<Program> getProgramsOfInstitution(int institutionId) {
    return programs
        .where((program) => program.institutionId == institutionId)
        .toList();
  }

  // Calculate average grade
  static double getAverageGrade(Program program) {
    final coursesOfProgram = CourseService.getFinishedCoursesOfProgram(program);

    final totalWeightedGrades = coursesOfProgram.fold<double>(0, (sum, course) {
      return sum +
          AssignmentService.getCourseGrade(course) *
              ClassService.getCourseCredits(course);
    });

    final totalCredits = coursesOfProgram.fold<int>(0, (sum, course) {
      return sum + ClassService.getCourseCredits(course);
    });

    return totalCredits > 0 ? totalWeightedGrades / totalCredits : 0.0;
  }

  // Calculate average GPA
  static double getAverageGPA(Program program) {
    final coursesOfProgram = CourseService.getFinishedCoursesOfProgram(program);

    final totalWeightedGPA = coursesOfProgram.fold<double>(0, (sum, course) {
      return sum +
          Convertions.gradeToGpa(AssignmentService.getCourseGrade(course)) *
              ClassService.getCourseCredits(course);
    });

    final totalCredits = coursesOfProgram.fold<int>(0, (sum, course) {
      return sum + ClassService.getCourseCredits(course);
    });

    return totalCredits > 0 ? totalWeightedGPA / totalCredits : 0.0;
  }

  // Get JSON representation of all programs
  static String getProgramsJson() {
    List<Map<String, dynamic>> programMaps =
        programs.map((program) => program.toJson()).toList();
    return jsonEncode(programMaps);
  }

  // Load programs from a JSON string
  static void loadProgramsFromJson(String jsonData) {
    List<dynamic> jsonList = jsonDecode(jsonData);
    programs = jsonList.map((json) => Program.fromJson(json)).toList();
  }

  // Load programs from a file
  static Future<void> loadProgramsFromFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/programs.json');

      if (await file.exists()) {
        String jsonData = await file.readAsString();
        loadProgramsFromJson(jsonData);
      } else {
        debugPrint("Programs file not found. Initializing with an empty list.");
      }
    } catch (e) {
      debugPrint("Error reading programs file: $e");
    }
  }

  // Save programs to a file
  static Future<void> saveProgramsToFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/programs.json');
      String jsonData = getProgramsJson();
      await file.writeAsString(jsonData);
    } catch (e) {
      debugPrint("Error writing programs to file: $e");
    }
  }
}
