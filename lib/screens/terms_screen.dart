import '../shared/colors.dart';
import 'courses_screen.dart';
import 'package:flutter/material.dart';
import '../models/program.dart';
import '../models/term.dart';
import '../shared/pick_date.dart';
import '../shared/dialog_message.dart';

class TermsScreen extends StatefulWidget {
  final Program program;

  TermsScreen({required this.program});

  @override
  _TermsScreenState createState() => _TermsScreenState(program: program);
}

class _TermsScreenState extends State<TermsScreen> {
  final Program program;

  _TermsScreenState({required this.program});

  // Method to generate term form
  Future<Term?> GenerateTermForm({int termId = 0}) async {
    Term? term;

    DateTime? selectedStartDate;
    DateTime? selectedEndDate;

    if (termId != 0) {
      term = TermService.findTermById(termId)!;

      selectedStartDate = term.startDate;
      selectedEndDate = term.endDate;
    }

    return showDialog<Term?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              termId != 0 ? 'Edit Term Information' : 'Enter Term Information'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Start Date Picker
                  FilledButton(
                    onPressed: () async {
                      selectedStartDate = await PickADate.SelectDate(
                          context, selectedStartDate);
                      if (selectedStartDate != null) {
                        setState(() {});
                      }
                    },
                    child: Text(
                      selectedStartDate == null
                          ? 'Select Start Date'
                          : 'Start Date: ${selectedStartDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  // End Date Picker
                  FilledButton(
                    onPressed: () async {
                      selectedEndDate =
                          await PickADate.SelectDate(context, selectedEndDate);
                      if (selectedEndDate != null) {
                        setState(() {});
                      }
                    },
                    child: Text(
                      selectedEndDate == null
                          ? 'Select End Date'
                          : 'End Date: ${selectedEndDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (selectedStartDate != null &&
                    selectedEndDate != null &&
                    selectedEndDate!.isAfter(selectedStartDate!)) {
                  setState(() {
                    term = Term(
                      termId: termId != 0
                          ? termId
                          : DateTime.now().millisecondsSinceEpoch,
                      programId: program.programId,
                      startDate: selectedStartDate!,
                      endDate: selectedEndDate!,
                    );
                  });

                  Navigator.of(context).pop(term);
                } else {
                  ShowMessageDialog(
                      'Error',
                      'Please select both start and end dates (start date should be before end date).',
                      context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to add a term
  Future<void> AddTerm() async {
    Term? newTerm = await GenerateTermForm();

    if (newTerm != null) {
      setState(() {
        TermService.addTerm(newTerm);
      });
    }
  }

  // Method to delete a term
  void DeleteTerm(Term term) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete this term and all its data (This action cannot be reversed?'),
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
                  TermService.deleteTerm(term.termId);
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

  // Method to edit a term
  Future<void> EditTerm(Term term) async {
    Term? updatedTerm = await GenerateTermForm(termId: term.termId);

    if (updatedTerm != null) {
      setState(() {
        TermService.editTerm(updatedTerm);
      });
    }
  }

  // Navigate to curses screen
  void ViewDetails(Term term) {
    int index =
        TermService.getTermsOfProgram(program.programId).indexOf(term) + 1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoursesScreen(term: term, termNumber: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms', style: TextStyle(color: MyColors.onSurface)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            color: MyColors.onSurface,
            onPressed: () => AddTerm(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount:
                  TermService.getTermsOfProgram(program.programId).length,
              itemBuilder: (context, index) {
                Term term =
                    TermService.getTermsOfProgram(program.programId)[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text("Term ${TermService.getTermNumber(term)}"),
                      subtitle: Text(
                          'Start: ${term.startDate.toLocal().toString().split(' ')[0]}\n'
                          'End: ${term.endDate.toLocal().toString().split(' ')[0]}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Details button
                          IconButton(
                            icon: Icon(Icons.description),
                            onPressed: () => ViewDetails(term),
                          ),
                          // Edit button
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => EditTerm(term),
                          ),
                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => DeleteTerm(term),
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
