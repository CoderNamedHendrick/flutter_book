import 'package:flutter/material.dart';
import 'appointments_entry.dart';
import 'appointments_list.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_model.dart' show appointmentsModel, AppointmentsModel;

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
              AppointMentsEntry(),
            ],
          );
        },
      ),
    );
  }
}
