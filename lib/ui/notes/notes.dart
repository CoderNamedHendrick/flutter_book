import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import '../../repositories/repositories.dart' show NotesDBWorker;
import 'notes_list.dart';
import 'notes_entry.dart';
import '../../models/models.dart' show NotesModel, notesModel;

class Notes extends StatelessWidget {
  Notes({Key? key}) : super(key: key) {
    notesModel.loadData('notes', NotesDBWorker.db);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (
          BuildContext inContext,
          Widget inChild,
          NotesModel inModel,
        ) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              const NotesList(),
              NotesEntry(),
            ],
          );
        },
      ),
    );
  }
}
