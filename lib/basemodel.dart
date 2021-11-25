// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';

class BaseModel extends Model {
  int stackIndex = 0;
  List entityList = [];
  var entityBeingEdited;
  String? chosenDate;

  void setChosenDate(String? inDate) {
    chosenDate = inDate;
    notifyListeners();
  }

  void loadData(String inEntityType, inDatabse) async {
    entityList = await inDatabse.getAll();
    notifyListeners();
  }

  void setStackIndex(int inStackIndex) {
    stackIndex = inStackIndex;
    notifyListeners();
  }
}
