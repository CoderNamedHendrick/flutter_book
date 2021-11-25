import 'package:flutter/material.dart';
import '../../models/models.dart' show TaskModel, tasksModel;
import 'tasks_entry.dart';
import 'tasks_list.dart';
import 'package:scoped_model/scoped_model.dart';

class Tasks extends StatelessWidget {
  const Tasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TaskModel>(
      model: tasksModel,
      child: ScopedModelDescendant(
        builder: (BuildContext inContext, Widget inChild, TaskModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              const TasksList(),
              TasksEntry(),
            ],
          );
        },
      ),
    );
  }
}
