import '../basemodel.dart';

class Note {
  int? id;
  String? title;
  String? content;
  String? color;

  @override
  String toString() {
    return '{id=$id, title=$title, content=$content, color=$color}';
  }
}

NotesModel notesModel = NotesModel();

class NotesModel extends BaseModel {
  String? color;

  void setColor(String? inColor) {
    color = inColor;
    notifyListeners();
  }
}
