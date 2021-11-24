import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'task_db_worker.dart';
import 'task_model.dart' show TaskModel, Task, tasksModel;

class TasksList extends StatelessWidget {
  const TasksList({Key? key}) : super(key: key);

  Future _deleteTask(BuildContext inContext, Task inTask) {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content:
              Text('Are you sure you want to delete ${inTask.description}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(inAlertContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await TasksDBWorker.db.delete(inTask.id!);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Task deleted'),
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
    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant(
        builder: (BuildContext inContext, Widget inChild, TaskModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                final Task task = tasksModel.entityList[inIndex];
                String? sDueDate;
                if (task.dueDate != null) {
                  final List dateParts = task.dueDate!.split(',');
                  final dueDate = DateTime(
                    int.parse(dateParts[0]),
                    int.parse(dateParts[1]),
                    int.parse(dateParts[2]),
                  );
                  sDueDate =
                      DateFormat.yMMMMd('en_US').format(dueDate.toLocal());
                }
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: .25,
                    children: [
                      SlidableAction(
                        label: 'Delete',
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        onPressed: (context) => _deleteTask(inContext, task),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.completed == 'true' ? true : false,
                      onChanged: (inValue) async {
                        task.completed = inValue.toString();
                        await TasksDBWorker.db.update(task);
                        tasksModel.loadData('tasks', TasksDBWorker.db);
                      },
                    ),
                    title: Text(
                      '${task.description}',
                      style: task.completed == 'true'
                          ? TextStyle(
                              color: Theme.of(inContext).disabledColor,
                              decoration: TextDecoration.lineThrough,
                            )
                          : TextStyle(
                              color: Theme.of(inContext)
                                  .textTheme
                                  .headline1!
                                  .color,
                            ),
                    ),
                    subtitle: task.dueDate == null
                        ? null
                        : Text(
                            sDueDate!,
                            style: task.completed == 'true'
                                ? TextStyle(
                                    color: Theme.of(inContext).disabledColor,
                                    decoration: TextDecoration.lineThrough,
                                  )
                                : TextStyle(
                                    color: Theme.of(inContext)
                                        .textTheme
                                        .headline1!
                                        .color),
                          ),
                    onTap: () async {
                      if (task.completed == 'true') {
                        return;
                      }
                      tasksModel.entityBeingEdited =
                          await TasksDBWorker.db.get(task.id!);
                      if (tasksModel.entityBeingEdited.dueDate == null) {
                        tasksModel.setChosenDate(null);
                      } else {
                        tasksModel.setChosenDate(sDueDate);
                      }
                      tasksModel.setStackIndex(1);
                    },
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
