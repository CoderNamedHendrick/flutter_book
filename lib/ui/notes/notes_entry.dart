import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../repositories/repositories.dart' show NotesDBWorker;
import '../../models/models.dart' show NotesModel, notesModel;

class NotesEntry extends StatelessWidget {
  NotesEntry({Key? key}) : super(key: key) {
    _titleEditingController.addListener(
      () {
        notesModel.entityBeingEdited.title = _titleEditingController.text;
      },
    );

    _contentEditingController.addListener(
      () {
        notesModel.entityBeingEdited.content = _contentEditingController.text;
      },
    );
  }
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _save(BuildContext inContext, NotesModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    } else {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }

    notesModel.loadData('notes', NotesDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Note saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = notesModel.entityBeingEdited.title;
    _contentEditingController.text = notesModel.entityBeingEdited.content;
    return ScopedModel(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget inChild, NotesModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _save(inContext, notesModel);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.title),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Title'),
                      controller: _titleEditingController,
                      validator: (String? inValue) {
                        if (inValue!.length == 0) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.content_paste),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: const InputDecoration(hintText: 'Content'),
                      controller: _contentEditingController,
                      validator: (String? inValue) {
                        if (inValue!.length == 0) {
                          return 'Please enter content';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: Row(
                      children: [
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: Border.all(width: 18, color: Colors.red) +
                                  Border.all(
                                    width: 6,
                                    color: notesModel.color == 'red'
                                        ? Colors.red
                                        : Theme.of(inContext).canvasColor,
                                  ),
                            ),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'red';
                            notesModel.setColor('red');
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape:
                                  Border.all(width: 18, color: Colors.green) +
                                      Border.all(
                                        width: 6,
                                        color: notesModel.color == 'green'
                                            ? Colors.green
                                            : Theme.of(inContext).canvasColor,
                                      ),
                            ),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'green';
                            notesModel.setColor('green');
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: Border.all(width: 18, color: Colors.blue) +
                                  Border.all(
                                    width: 6,
                                    color: notesModel.color == 'blue'
                                        ? Colors.blue
                                        : Theme.of(inContext).canvasColor,
                                  ),
                            ),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'blue';
                            notesModel.setColor('blue');
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape:
                                  Border.all(width: 18, color: Colors.yellow) +
                                      Border.all(
                                        width: 6,
                                        color: notesModel.color == 'yellow'
                                            ? Colors.yellow
                                            : Theme.of(inContext).canvasColor,
                                      ),
                            ),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'yellow';
                            notesModel.setColor('yellow');
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape: Border.all(width: 18, color: Colors.grey) +
                                  Border.all(
                                    width: 6,
                                    color: notesModel.color == 'grey'
                                        ? Colors.grey
                                        : Theme.of(inContext).canvasColor,
                                  ),
                            ),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'grey';
                            notesModel.setColor('grey');
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          child: Container(
                            decoration: ShapeDecoration(
                              shape:
                                  Border.all(width: 18, color: Colors.purple) +
                                      Border.all(
                                        width: 6,
                                        color: notesModel.color == 'purple'
                                            ? Colors.purple
                                            : Theme.of(inContext).canvasColor,
                                      ),
                            ),
                          ),
                          onTap: () {
                            notesModel.entityBeingEdited.color = 'purple';
                            notesModel.setColor('purple');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
