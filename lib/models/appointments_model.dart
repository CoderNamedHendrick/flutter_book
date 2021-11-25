import '../basemodel.dart';

class Appointment {
  int? id;
  String? title;
  String? description;
  String? apptDate;
  String? apptTime;

  @override
  String toString() {
    return '{id:$id, title:$title, description:$description, '
        'appointment-date:$apptDate, appointment-time:$apptTime}';
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();

class AppointmentsModel extends BaseModel {
  String? apptTime;
  void setApptTime(String? inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }
}
