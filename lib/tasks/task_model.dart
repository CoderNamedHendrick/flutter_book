import '../basemodel.dart';

class Task {
  int? id;
  String? description;
  String? dueDate;
  String? completed = 'false';

  @override
  String toString() => '{id:$id, description:$description, dueDate:$dueDate, '
      'complete:$completed}';
}

class TaskModel extends BaseModel {}
