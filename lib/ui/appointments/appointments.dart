import 'package:flutter/material.dart';
import 'appointments_entry.dart';
import 'appointments_list.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import '../../models/models.dart' show appointmentsModel, AppointmentsModel;

class Appointments extends StatelessWidget {
  const Appointments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant(
        builder: (BuildContext inContext, Widget inChild,
            AppointmentsModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              const AppointmentsList(),
              AppointmentsEntry(),
            ],
          );
        },
      ),
    );
  }
}
