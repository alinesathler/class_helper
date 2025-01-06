import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../shared/get_diretory.dart';
import 'program.dart';
import 'selectable.dart';
import 'package:collection/collection.dart';

class Institution extends Selectable {
  int institutionId;
  String name;
  String address;
  LatLng coordinates;

  Institution({
    required this.institutionId,
    required this.name,
    required this.address,
    required this.coordinates,
  });

  // Serialize the Institution to JSON
  Map<String, dynamic> toJson() {
    return {
      'institutionId': institutionId,
      'name': name,
      'address': address,
      'coordinates': {
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
      },
    };
  }

  // Deserialize JSON to an Institution
  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      institutionId: json['institutionId'],
      name: json['name'],
      address: json['address'],
      coordinates: LatLng(
        json['coordinates']['latitude'],
        json['coordinates']['longitude'],
      ),
    );
  }

  @override
  String toString() {
    return 'Institution{institutionId: $institutionId, name: $name, address: $address, coordinates: $coordinates}';
  }
}

class InstitutionService {
  // In-memory storage
  static List<Institution> institutions = [];

  // Add an institution
  static void addInstitution(Institution institution) {
    if (institutions
        .any((inst) => inst.institutionId == institution.institutionId)) {
      debugPrint(
          'Institution with ID ${institution.institutionId} already exists.');
      return;
    }

    institutions.add(institution);
    saveInstitutionsToFile();

    debugPrint('Institution added: ${institution.toString()}');
  }

  // Delete an institution by ID
  static void deleteInstitution(int institutionId) {
    var programsOfInstitution =
        ProgramService.getProgramsOfInstitution(institutionId);

    // Delete all programs associated with the institution
    for (var program in programsOfInstitution) {
      ProgramService.deleteProgram(program.programId);
    }

    int index = institutions.indexWhere(
        (institution) => institution.institutionId == institutionId);

    if (index != -1) {
      institutions.removeAt(index);

      debugPrint("Institution deleted: " + institutionId.toString());
    }

    saveInstitutionsToFile();
  }

  // Edit an institution by ID
  static void editInstitution(Institution updatedInstitution) {
    int index = institutions.indexWhere((institution) =>
        institution.institutionId == updatedInstitution.institutionId);
    if (index != -1) {
      institutions[index] = updatedInstitution;

      debugPrint("Institution edited: " + updatedInstitution.toString());
    }

    saveInstitutionsToFile();
  }

  // Method to find a institution by its ID
  static Institution? findInstitutionById(int id) {
    return institutions
        .firstWhereOrNull((institution) => institution.institutionId == id);
  }

  static List<Institution> getAllInstitutions() {
    return List.unmodifiable(institutions);
  }

  // Convert all institutions to JSON
  static String getInstitutionsJson() {
    List<Map<String, dynamic>> institutionMaps =
        institutions.map((institution) => institution.toJson()).toList();
    return jsonEncode(institutionMaps);
  }

  // Load institutions from JSON string
  static void loadInstitutionsFromJson(String jsonData) {
    List<dynamic> jsonList = jsonDecode(jsonData);
    institutions = jsonList.map((json) => Institution.fromJson(json)).toList();
  }

  static Future<void> loadInstitutionsFromFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/institutions.json');

      // Check if the file exists
      if (await file.exists()) {
        String jsonData = await file.readAsString();
        loadInstitutionsFromJson(jsonData);
      } else {
        // Handle the case where the file does not exist
        debugPrint("File not found, initializing with empty data.");
      }
    } catch (e) {
      debugPrint("Error reading file: $e");
    }
  }

  // Save institutions to a file
  static Future<void> saveInstitutionsToFile() async {
    try {
      String path = await getFilePath();
      final file = File('$path/institutions.json');

      // Get JSON data from the institutions
      String jsonData = getInstitutionsJson();

      // Write the JSON data to the file
      await file.writeAsString(jsonData);
    } catch (e) {
      debugPrint("Error writing to file: $e");
    }
  }
}
