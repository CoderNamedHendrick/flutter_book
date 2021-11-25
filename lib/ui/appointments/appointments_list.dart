import 'package:flutter/material.dart';
import '../../repositories/repositories.dart' show AppointmentsDBWorker;
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:scoped_model/scoped_model.dart';
import '../../models/models.dart'
    show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({Key? key}) : super(key: key);

  Future _deleteAppointment(BuildContext inContext, Appointment inAppointment) {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text('Delete Appointment'),
          content:
              Text('Are you sure you want to delete ${inAppointment.title}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(inAlertContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await AppointmentsDBWorker.db.delete(inAppointment.id!);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                    content: Text('Appointment deleted'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editAppointment(
      BuildContext inContext, Appointment inAppointment) async {
    appointmentsModel.entityBeingEdited =
        await AppointmentsDBWorker.db.get(inAppointment.id!);
    if (appointmentsModel.entityBeingEdited.apptDate == null) {
      appointmentsModel.setChosenDate(null);
    } else {
      final dateParts = appointmentsModel.entityBeingEdited.apptDate.split(',');
      final apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      appointmentsModel.setChosenDate(
        DateFormat.yMMMMd('en_US').format(
          apptDate.toLocal(),
        ),
      );
    }

    if (appointmentsModel.entityBeingEdited.apptTime == null) {
      appointmentsModel.setApptTime(null);
    } else {
      final timeParts = appointmentsModel.entityBeingEdited.apptTime.split(',');
      final apptTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      appointmentsModel.setApptTime(apptTime.format(inContext));
    }
    appointmentsModel.setStackIndex(1);
    Navigator.pop(inContext);
  }

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    showModalBottomSheet(
      context: inContext,
      builder: (BuildContext inContext) {
        return ScopedModel<AppointmentsModel>(
          model: appointmentsModel,
          child: ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext inContext, Widget inChild,
                AppointmentsModel inModel) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    child: Column(
                      children: [
                        Text(
                          DateFormat.yMMMd('en_US').format(
                            inDate.toLocal(),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(inContext).colorScheme.secondary,
                            fontSize: 24,
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: appointmentsModel.entityList.length,
                            itemBuilder:
                                (BuildContext inBuildContext, int inIndex) {
                              final appointment =
                                  appointmentsModel.entityList[inIndex];
                              if (appointment.apptDate !=
                                  '${inDate.year},'
                                      '${inDate.month},${inDate.day}') {
                                return Container(height: 0);
                              }
                              var apptTime = '';
                              if (appointment.apptTime != null) {
                                final timeParts =
                                    appointment.apptTime!.split(',');
                                final at = TimeOfDay(
                                  hour: int.parse(timeParts[0]),
                                  minute: int.parse(timeParts[1]),
                                );
                                apptTime = ' (${at.format(inContext)})';
                              }
                              return Slidable(
                                endActionPane: ActionPane(
                                  extentRatio: .25,
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) =>
                                          _deleteAppointment(
                                              inBuildContext, appointment),
                                      icon: Icons.delete,
                                      label: 'Delete',
                                      backgroundColor: Colors.red,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: Colors.grey.shade300,
                                  child: ListTile(
                                    title: Text('${appointment.title} '
                                        '$apptTime'),
                                    subtitle: appointment.description == null
                                        ? null
                                        : Text('${appointment.description}'),
                                    onTap: () async {
                                      _editAppointment(inContext, appointment);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _markedDateMap = EventList(
      events: Map<DateTime, List<Event>>(),
    );
    for (var i = 0; i < appointmentsModel.entityList.length; i++) {
      final appointment = appointmentsModel.entityList[i];
      final dateParts = appointment.apptDate!.split(',');
      final apptDate = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      _markedDateMap.add(
        apptDate,
        Event(
          date: apptDate,
          icon: Container(
            decoration: const BoxDecoration(color: Colors.blue),
          ),
        ),
      );
    }
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget inChild,
            AppointmentsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                final now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate = '${now.year},'
                    '${now.month},${now.day}';
                appointmentsModel.setChosenDate(
                  DateFormat.yMMMMd('en_US').format(
                    now.toLocal(),
                  ),
                );
                appointmentsModel.setApptTime(null);
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: false,
                      markedDatesMap: _markedDateMap,
                      onDayPressed: (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, inContext);
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
