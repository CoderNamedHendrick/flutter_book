import 'package:flutter/material.dart';
import 'tasks_entry.dart';
import 'tasks_list.dart';
import 'package:scoped_model/scoped_model.dart';
import 'task_model.dart' show tasksModel, TaskModel;

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
