import 'dart:io';
import '../../repositories/repositories.dart' show ContactsDBWorker;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import '../../models/models.dart' show ContactsModel, Contact, contactsModel;
import '../../utils.dart' as utils;

class ContactsList extends StatelessWidget {
  const ContactsList({Key? key}) : super(key: key);

  Future _deleteContact(BuildContext inContext, Contact contact) async {
    return showDialog(
      context: inContext,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: Text('Are you sure you want to delete ${contact.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(inAlertContext).pop,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final avatarFile = File(
                  join(utils.docsDir!.path, contact.id.toString()),
                );
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                await ContactsDBWorker.db.delete(contact.id!);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Contact deleted'),
                  ),
                );
                contactsModel.loadData('contacts', ContactsDBWorker.db);
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
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder:
            (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final avatarFile = File(join(utils.docsDir!.path, 'avatar'));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }

                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(null);
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                final contact = contactsModel.entityList[inIndex];
                final avatarFile = File(
                  join(
                    utils.docsDir!.path,
                    contact.id.toString(),
                  ),
                );
                final avatarFileExists = avatarFile.existsSync();
                return Column(
                  children: [
                    Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: .25,
                        children: [
                          SlidableAction(
                            onPressed: (context) =>
                                _deleteContact(inContext, contact),
                            icon: Icons.delete,
                            backgroundColor: Colors.red,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage:
                              avatarFileExists ? FileImage(avatarFile) : null,
                          child: avatarFileExists
                              ? null
                              : Text(
                                  contact.name!.substring(0, 1).toUpperCase(),
                                ),
                        ),
                        title: Text('${contact.name}'),
                        subtitle: contact.phone == null
                            ? null
                            : Text('${contact.phone}'),
                        onTap: () async {
                          final avatarFile =
                              File(join(utils.docsDir!.path, 'avatar'));
                          if (avatarFile.existsSync()) {
                            avatarFile.deleteSync();
                          }
                          contactsModel.entityBeingEdited =
                              await ContactsDBWorker.db.get(contact.id);

                          if (contactsModel.entityBeingEdited.birthday ==
                              null) {
                            contactsModel.setChosenDate(null);
                          } else {
                            final dateParts = contactsModel
                                .entityBeingEdited.birthday
                                .split(',');
                            final birthday = DateTime(
                              int.parse(dateParts[0]),
                              int.parse(dateParts[1]),
                              int.parse(dateParts[2]),
                            );

                            contactsModel.setChosenDate(
                              DateFormat.yMMMMd('en_US').format(
                                birthday.toLocal(),
                              ),
                            );
                            contactsModel.setStackIndex(1);
                          }
                        },
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
