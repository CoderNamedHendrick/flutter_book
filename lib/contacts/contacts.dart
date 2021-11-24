import 'package:flutter/material.dart';
import 'contacts_entry.dart';
import 'contacts_list.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_model.dart' show contactsModel, ContactsModel;

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
