import 'dart:io';
import '../../repositories/repositories.dart' show ContactsDBWorker;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import '../../utils.dart' as utils;
import '../../models/models.dart' show contactsModel, ContactsModel;

class ContactsEntry extends StatelessWidget {
  ContactsEntry({Key? key}) : super(key: key) {
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });

    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });

    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
  }

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _save(BuildContext inContext, ContactsModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (inModel.entityBeingEdited.id == null) {
      final id = await ContactsDBWorker.db.create(
        contactsModel.entityBeingEdited,
      );
      final avatarFile = File(join(utils.docsDir!.path, 'avatar'));
      if (avatarFile.existsSync()) {
        avatarFile.renameSync(
          join(
            utils.docsDir!.path,
            id.toString(),
          ),
        );
      }
    } else {
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
      final avatarFile = File(join(utils.docsDir!.path, 'avatar'));
      if (avatarFile.existsSync()) {
        avatarFile.renameSync(
          join(
            utils.docsDir!.path,
            contactsModel.entityBeingEdited.id.toString(),
          ),
        );
      }
    }

    contactsModel.loadData('contacts', ContactsDBWorker.db);
    inModel.setStackIndex(0);

    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Contact saved'),
      ),
    );
  }

  Future _selectAvatar(BuildContext inContext) {
    return showDialog(
      context: inContext,
      builder: (BuildContext inDialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: const Text('Take a picture'),
                  onTap: () async {
                    final cameraImage = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    );
                    if (cameraImage != null) {
                      if (File(join(utils.docsDir!.path, 'avatar'))
                          .existsSync()) {
                        File(join(utils.docsDir!.path, 'avatar')).deleteSync();
                      }
                      File(cameraImage.path).copySync(
                        join(utils.docsDir!.path, 'avatar'),
                      );
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(inDialogContext).pop();
                  },
                ),
                GestureDetector(
                  child: const Text('Select From Gallery'),
                  onTap: () async {
                    final galleryImage = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (galleryImage != null) {
                      if (File(join(utils.docsDir!.path, 'avatar'))
                          .existsSync()) {
                        File(join(utils.docsDir!.path, 'avatar')).deleteSync();
                      }
                      File(galleryImage.path).copySync(
                        join(utils.docsDir!.path, 'avatar'),
                      );
                      contactsModel.triggerRebuild();
                    }
                    Navigator.of(inDialogContext).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _nameEditingController.text = contactsModel.entityBeingEdited.name;
    _emailEditingController.text = contactsModel.entityBeingEdited.email;
    _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder:
            (BuildContext inContext, Widget inChild, ContactsModel inModel) {
          var avatarFile = File(join(utils.docsDir!.path, 'avatar'));
          if (avatarFile.existsSync() == false) {
            if (inModel.entityBeingEdited != null &&
                inModel.entityBeingEdited.id != null) {
              avatarFile = File(
                join(
                  utils.docsDir!.path,
                  inModel.entityBeingEdited.id.toString(),
                ),
              );
            }
          }
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      final avatarFile = File(
                        join(utils.docsDir!.path, 'avatar'),
                      );
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _save(inContext, inModel),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    title: avatarFile.existsSync()
                        ? CircleAvatar(
                            backgroundImage: FileImage(
                              avatarFile,
                            ),
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            minRadius: 64,
                            maxRadius: 64,
                          )
                        : const Text('No avatar image for this contact'),
                    trailing: IconButton(
                      onPressed: () => _selectAvatar(inContext),
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Name'),
                      controller: _nameEditingController,
                      validator: (String? inValue) {
                        if (inValue!.length == 0) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: 'Phone'),
                      controller: _phoneEditingController,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'Email'),
                      controller: _emailEditingController,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text('Birthday'),
                    subtitle: Text(contactsModel.chosenDate == null
                        ? ''
                        : contactsModel.chosenDate!),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        final chosenDate = await utils.selectDate(
                          inContext,
                          contactsModel,
                          contactsModel.entityBeingEdited.birthday,
                        );
                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited.birthday = chosenDate;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
