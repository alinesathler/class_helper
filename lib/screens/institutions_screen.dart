import '../models/institution.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../shared/colors.dart';
import '../shared/dialog_message.dart';
import '../models/program.dart';
import '../shared/pick_location.dart';

class InstitutionsScreen extends StatefulWidget {
  @override
  _InstitutionsScreenState createState() => _InstitutionsScreenState();
}

class _InstitutionsScreenState extends State<InstitutionsScreen> {
  final TextEditingController _institutionNameController =
      TextEditingController();
  String? selectedAddress;
  LatLng? selectedLatLng;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _institutionNameController.dispose();
    super.dispose();
  }

  Future<void> _selectLocation() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: double.infinity,
          height: 500,
          child: PickerLocation(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedAddress = result["address"];
        selectedLatLng = result["coordinates"];
      });
    }
  }

  Future<Institution?> GenerateInstitutionForm({int institutionId = 0}) async {
    Institution? institution;

    if (institutionId != 0) {
      institution = InstitutionService.findInstitutionById(institutionId);
      if (institution != null) {
        _institutionNameController.text = institution.name;
        selectedAddress = institution.address;
        selectedLatLng = institution.coordinates;
      }
    }

    return showDialog<Institution?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(institutionId != 0
              ? 'Edit Institution Information'
              : 'Enter Institution Information'),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: TextField(
                        controller: _institutionNameController,
                        decoration:
                            InputDecoration(hintText: 'Institution Name'),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        await _selectLocation();
                        setDialogState(() {});
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: MyColors.onSurface,
                          ),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(selectedAddress ?? "Select Location",
                                style: TextStyle(
                                    color: MyColors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                                softWrap: true, // Ensures the text wraps
                                overflow: TextOverflow
                                    .visible // Ensures the text is not clipped
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                _institutionNameController.clear();
                selectedLatLng = null;
                selectedAddress = null;
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (_institutionNameController.text.isNotEmpty &&
                    selectedLatLng != null &&
                    selectedAddress != null) {
                  final newInstitution = Institution(
                    institutionId: institutionId != 0
                        ? institutionId
                        : DateTime.now().millisecondsSinceEpoch,
                    name: _institutionNameController.text,
                    address: selectedAddress!,
                    coordinates: selectedLatLng!,
                  );
                  Navigator.of(context).pop(newInstitution);
                } else {
                  ShowMessageDialog(
                      'Error', 'Please complete all fields.', context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to add institution
  Future<void> AddInstitution() async {
    Institution? institution = await GenerateInstitutionForm();

    if (institution != null) {
      setState(() {
        InstitutionService.addInstitution(institution);
      });
    }
  }

  // Method to delete institution
  void DeleteInstitution(Institution institution) {
    List<Program>? programs =
        ProgramService.getProgramsOfInstitution(institution.institutionId);

    int programCount = programs.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'This institution has $programCount programs, you sure you want to delete this institution and all its data (This action cannot be reversed)?'),
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
                  InstitutionService.deleteInstitution(
                      institution.institutionId);
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

  // Method to edit institution
  void EditInstitution(Institution institution) async {
    Institution? institutionToUpdate =
        await GenerateInstitutionForm(institutionId: institution.institutionId);

    if (institutionToUpdate != null) {
      setState(() {
        InstitutionService.editInstitution(institutionToUpdate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Institutions', style: TextStyle(color: MyColors.onSurface)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: MyColors.onSurface,
            onPressed: () => AddInstitution(),
          ),
        ],
      ),
      body: Expanded(
        child: ListView.builder(
          itemCount: InstitutionService.getAllInstitutions().length,
          itemBuilder: (context, index) {
            Institution institution =
                InstitutionService.getAllInstitutions()[index];
            return Column(
              children: [
                ListTile(
                  title: Text(institution.name),
                  subtitle: Text(institution.address),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => EditInstitution(institution),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => DeleteInstitution(institution),
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
    );
  }
}
