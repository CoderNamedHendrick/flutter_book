import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  const NotesList({Key? key}) : super(key: key);

  Future _deleteNote(BuildContext inContext, Note inNote) {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: Text('Are you sure you want to delete ${inNote.title}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(inAlertContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await NotesDBWorker.db.delete(inNote.id!);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Note deleted'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget inChild, NotesModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                notesModel.entityBeingEdited = Note();
                notesModel.setColor(null);
                notesModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: notesModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                final note = notesModel.entityList[inIndex];
                var color = Colors.white;
                switch (note.color) {
                  case 'red':
                    color = Colors.red;
                    break;
                  case 'green':
                    color = Colors.green;
                    break;
                  case 'blue':
                    color = Colors.blue;
                    break;
                  case 'yellow':
                    color = Colors.yellow;
                    break;
                  case 'grey':
                    color = Colors.grey;
                    break;
                  case 'purple':
                    color = Colors.purple;
                    break;
                }
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 29, 0),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: .25,
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _deleteNote(inContext, note);
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Delete',
                        )
                      ],
                    ),
                    child: Card(
                      elevation: 8,
                      color: color,
                      child: ListTile(
                        title: Text('${note.title}'),
                        subtitle: Text('${note.content}'),
                        onTap: () async {
                          notesModel.entityBeingEdited =
                              await NotesDBWorker.db.get(note.id);
                          notesModel
                              .setColor(notesModel.entityBeingEdited.color);
                          notesModel.setStackIndex(1);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
