import '../models/institution.dart';
import 'package:flutter/material.dart';
import '../shared/colors.dart';
import '../models/program.dart';
import 'terms_screen.dart';
import '../shared/dialog_message.dart';

class ProgramsScreen extends StatefulWidget {
  // Using a ValueKey ensures that the screen will rebuild properly when navigating.
  ProgramsScreen({Key? key}) : super(key: key);

  @override
  _ProgramsScreenState createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  final TextEditingController _programNameController = TextEditingController();

  @override
  void dispose() {
    _programNameController.dispose();
    super.dispose();
  }

  // List of numbers from 1 to 10 for terms
  List<int> termsList = List.generate(10, (index) => index + 1);

  // Method to generate program form
  Future<Program?> GenerateProgramForm({int programId = 0}) async {
    Program? program;
    Institution? selectedInstitution;

    if (programId != 0) {
      program = ProgramService.findProgramById(programId)!;

      _programNameController.text = program.name;

      if (program.institutionId != null) {
        selectedInstitution =
            InstitutionService.findInstitutionById(program.institutionId!);
      }
    }

    return showDialog<Program?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(programId != 0
              ? 'Edit Program Information'
              : 'Enter Program Information'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: TextField(
                      controller: _programNameController,
                      decoration: InputDecoration(hintText: 'Program name'),
                    ),
                  ),
                  // Institution Dropdown
                  Flexible(
                      child: DropdownButton<Institution>(
                    hint: Text('Select Institution'),
                    value: selectedInstitution,
                    items: InstitutionService.getAllInstitutions().isEmpty
                        ? [
                            DropdownMenuItem<Institution>(
                              value: null,
                              child: Text(
                                'No institutions available.',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]
                        : InstitutionService.institutions
                            .map<DropdownMenuItem<Institution>>(
                                (Institution value) {
                            return DropdownMenuItem<Institution>(
                              value: value,
                              child: Text(
                                value.name,
                                overflow: TextOverflow.visible,
                              ),
                            );
                          }).toList(),
                    onChanged: (Institution? value) {
                      setState(() {
                        selectedInstitution = value;
                      });
                    },
                  )),
                ],
              );
            },
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                _programNameController.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                String programName = _programNameController.text;

                // Validate inputs
                if (programName.isNotEmpty) {
                  setState(() {
                    program = Program(
                        programId: programId != 0
                            ? programId
                            : DateTime.now().millisecondsSinceEpoch,
                        name: programName,
                        institutionId: selectedInstitution?.institutionId);
                  });

                  // Clear inputs
                  _programNameController.clear();

                  Navigator.of(context).pop(program); // Close the dialog
                } else {
                  ShowMessageDialog(
                      'Error', 'Please enter a program name.', context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to add a program
  Future<void> AddProgram() async {
    Program? newProgram = await GenerateProgramForm();

    if (newProgram != null) {
      setState(() {
        ProgramService.addProgram(newProgram);
      });
    }
  }

  // Confirm and delete a program
  void DeleteProgram(Program program) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete this program and all its data (This action cannot be reversed)?'),
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
                  ProgramService.deleteProgram(program.programId);
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

  // Method to edit a program
  Future<void> EditProgram(Program program) async {
    Program? updatedProgram =
        await GenerateProgramForm(programId: program.programId);

    if (updatedProgram != null) {
      setState(() {
        ProgramService.editProgram(updatedProgram);
      });
    }
  }

  // Navigate to terms screen
  void ViewDetails(Program program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TermsScreen(program: program),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Programs', style: TextStyle(color: MyColors.onSurface)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              color: MyColors.onSurface,
              onPressed: () => AddProgram(),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: ProgramService.getAllPrograms().length,
                itemBuilder: (context, index) {
                  Program program = ProgramService.getAllPrograms()[index];
                  return Column(
                    children: [
                      ListTile(
                        title: Text(program.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Details button
                            IconButton(
                              icon: Icon(Icons.description),
                              onPressed: () => ViewDetails(program),
                            ),
                            // Edit button
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => EditProgram(program),
                            ),
                            // Delete button
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => DeleteProgram(program),
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
        ));
  }
}
