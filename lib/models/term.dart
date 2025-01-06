import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../shared/get_diretory.dart';
import 'course.dart';
import 'selectable.dart';
import 'package:collection/collection.dart';

class Term extends Selectable {
  int termId;
  DateTime startDate;
  DateTime endDate;
  int programId; // Foreign key

  Term({
    required this.termId,
    required this.startDate,
    required this.endDate,
    required this.programId,
  });

  // Serialize Term to JSON
  Map<String, dynamic> toJson() {
    return {
      'termId': termId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'programId': programId,
    };
  }

  // Deserialize JSON to a Term
  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      termId: json['termId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      programId: json['programId'],
    );
  }

  @override
  String toString() {
    return 'Term{termId: $termId, startDate: $startDate, endDate: $endDate, programId: $programId}';
  }
}

class TermService {
  static List<Term> terms = [];

  // Add a term
  static void addTerm(Term term) {
    if (terms.any((term1) => term1.termId == term.termId)) {
      debugPrint('Term with ID ${term.termId} already exists.');
      return;
    }

    terms.add(term);
    saveTermsToFile();

    debugPrint('Program edited: ${term.toString()}');
  }

  // Delete a term
  static void deleteTerm(int termId) {
    int index = terms.indexWhere((term) => term.termId == termId);
    if (index != -1) {
      // Delete all courses associated with this term
      for (var course in CourseService.getCoursesOfTerm(terms[index].termId)) {
        CourseService.deleteCourse(course.courseId);
      }

      terms.removeAt(index);

      debugPrint('Term with ID $termId deleted.');
    }

    saveTermsToFile();
  }

  // Edit a term
  static void editTerm(Term updatedTerm) {
    int index = terms.indexWhere((term) => term.termId == updatedTerm.termId);
    if (index != -1) {
      terms[index] = updatedTerm;

      debugPrint('Term edited: ${updatedTerm.toString()}');
    }
    saveTermsToFile();
  }

  // Find a term by ID
  static Term? findTermById(int termId) {
    return terms.firstWhereOrNull((term) => term.termId == termId);
  }

  // Get all terms
  static List<Term> getAllTerms() {
    terms.sort((a, b) => a.startDate.compareTo(b.startDate));
    return List.unmodifiable(terms);
  }

  // Get terms of a specific program
  static List<Term> getTermsOfProgram(int programId) {
    return terms.where((term) => term.programId == programId).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

// Get the term number of a term in a program
  static int getTermNumber(Term term) {
    return getTermsOfProgram(term.programId).indexOf(term) + 1;
  }

  // Get JSON representation of all terms
  static String getTermsJson() {
    List<Map<String, dynamic>> termMaps =
        terms.map((term) => term.toJson()).toList();
    return jsonEncode(termMaps);
  }

  // Load terms from a JSON string
  static void loadTermsFromJson(String jsonData) {
    List<dynamic> jsonList = jsonDecode(jsonData);
    terms = jsonList.map((json) => Term.fromJson(json)).toList();
  }

  // Load terms from a file
  static Future<void> loadTermsFromFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/terms.json');

      if (await file.exists()) {
        String jsonData = await file.readAsString();
        loadTermsFromJson(jsonData);
      } else {
        debugPrint("Terms file not found. Initializing with an empty list.");
      }
    } catch (e) {
      debugPrint("Error reading terms file: $e");
    }
  }

  // Save terms to a file
  static Future<void> saveTermsToFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/terms.json');
      String jsonData = getTermsJson();
      await file.writeAsString(jsonData);
    } catch (e) {
      debugPrint("Error writing terms to file: $e");
    }
  }
}
