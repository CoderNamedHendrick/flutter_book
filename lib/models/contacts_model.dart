import '../basemodel.dart';

class Contact {
  int? id;
  String? name;
  String? phone;
  String? email;
  String? birthday;

  @override
  String toString() {
    return '''
    id: $id,
    name: $name,
    phone: $phone,
    email: $email,
    birthday: $birthday
    ''';
  }
}

ContactsModel contactsModel = ContactsModel();

class ContactsModel extends BaseModel {
  void triggerRebuild() {
    notifyListeners();
  }
}
