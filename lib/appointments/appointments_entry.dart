import 'package:flutter/material.dart';
import 'appointments_db_worker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_model.dart' show appointmentsModel, AppointmentsModel;
import '../utils.dart' as utils;

class AppointmentsEntry extends StatelessWidget {
  AppointmentsEntry({Key? key}) : super(key: key) {
    _titleEditingController.addListener(
      () {
        appointmentsModel.entityBeingEdited.title =
            _titleEditingController.text;
      },
    );

    _descriptionController.addListener(
      () {
        appointmentsModel.entityBeingEdited.description =
            _descriptionController.text;
      },
    );
  }

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _save(BuildContext inContext, AppointmentsModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (inModel.entityBeingEdited.id == null) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData('appointments', AppointmentsDBWorker.db);
    inModel.setStackIndex(0);

    ScaffoldMessenger.of(inContext).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text('Appointment saved'),
      ),
    );
  }

  Future _selectTime(BuildContext inContext) async {
    var initialTime = TimeOfDay.now();

    if (appointmentsModel.entityBeingEdited.apptTime != null) {
      final timeParts = appointmentsModel.entityBeingEdited.apptTime.split(',');
      initialTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

    final picked =
        await showTimePicker(context: inContext, initialTime: initialTime);

    if (picked != null) {
      appointmentsModel.entityBeingEdited.apptTime =
          '${picked.hour},${picked.minute}';
      appointmentsModel.setApptTime(picked.format(inContext));
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleEditingController.text = appointmentsModel.entityBeingEdited.title;
    _descriptionController.text =
        appointmentsModel.entityBeingEdited.description;
    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild,
            AppointmentsModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _save(inContext, appointmentsModel),
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
                    leading: const Icon(Icons.title),
                    title: TextFormField(
                      decoration: const InputDecoration(hintText: 'Title'),
                      controller: _titleEditingController,
                      validator: (String? inValue) {
                        if (inValue!.length == 0) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.content_paste),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration:
                          const InputDecoration(hintText: 'Description'),
                      controller: _descriptionController,
                      validator: (String? inValue) {
                        if (inValue!.length == 0) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text('Date'),
                    subtitle: Text(appointmentsModel.chosenDate == null
                        ? ''
                        : appointmentsModel.chosenDate!),
                    trailing: IconButton(
                      onPressed: () async {
                        final chosenDate = await utils.selectDate(
                          inContext,
                          appointmentsModel,
                          appointmentsModel.entityBeingEdited.apptDate,
                        );
                        if (chosenDate != null) {
                          appointmentsModel.entityBeingEdited.apptDate =
                              chosenDate;
                        }
                      },
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.alarm),
                    title: const Text('Time'),
                    subtitle: Text(appointmentsModel.apptTime == null
                        ? ''
                        : appointmentsModel.apptTime!),
                    trailing: IconButton(
                      onPressed: () => _selectTime(inContext),
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
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
