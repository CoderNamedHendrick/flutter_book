import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'task_db_worker.dart';
import 'task_model.dart' show TaskModel, tasksModel;
import '../utils.dart' as utils;

class TasksEntry extends StatelessWidget {
  TasksEntry({Key? key}) : super(key: key) {
    _descriptionController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionController.text;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  void _save(BuildContext inContext, TaskModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData('tasks', TasksDBWorker.db);
    inModel.setStackIndex(0);
    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Task saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _descriptionController.text = tasksModel.entityBeingEdited.description;
    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant(
        builder: (BuildContext inContext, Widget inChild, TaskModel inModel) {
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
                      _save(inContext, tasksModel);
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
                    leading: const Icon(Icons.content_paste),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: const InputDecoration(
                          hintText: 'Task '
                              'Description'),
                      controller: _descriptionController,
                      validator: (String? inValue) {
                        if (inValue!.length == 0) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text('Due Date'),
                    subtitle: Text(tasksModel.chosenDate == null
                        ? ''
                        : tasksModel.chosenDate!),
                    trailing: IconButton(
                      onPressed: () async {
                        final chosenDate = await utils.selectDate(
                          inContext,
                          tasksModel,
                          tasksModel.entityBeingEdited.dueDate,
                        );
                        if (chosenDate != null) {
                          tasksModel.entityBeingEdited.dueDate = chosenDate;
                        }
                      },
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
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
