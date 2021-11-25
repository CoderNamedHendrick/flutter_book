import 'package:flutter/material.dart';
import 'contacts_entry.dart';
import 'contacts_list.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import '../../models/models.dart' show contactsModel, ContactsModel;

class Contacts extends StatelessWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant(
        builder:
            (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          return IndexedStack(
            index: contactsModel.stackIndex,
            children: [
              const ContactsList(),
              ContactsEntry(),
            ],
          );
        },
      ),
    );
  }
}
