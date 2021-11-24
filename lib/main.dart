import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'appointments/appointments.dart';
import 'contacts/contacts.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';
import 'utils.dart' as utils;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  void startMeUp() async {
    final docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(const FlutterBook());
  }

  startMeUp();
}

class FlutterBook extends StatelessWidget {
  const FlutterBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Book',
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('FlutterBook'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.date_range),
                  text: 'Appointments',
                ),
                Tab(
                  icon: Icon(Icons.contacts),
                  text: 'Contacts',
                ),
                Tab(
                  icon: Icon(Icons.note),
                  text: 'Notes',
                ),
                Tab(
                  icon: Icon(Icons.assignment_turned_in),
                  text: 'Tasks',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Appointments(),
              Contacts(),
              Notes(),
              Tasks(),
            ],
          ),
        ),
      ),
    );
  }
}
