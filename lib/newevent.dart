import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class NewEventPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Form Validation Demo';

    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
      ),
      body: NewEventForm(),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
        },
        label: Text('Add participants'),
        tooltip: 'Add participants to event',
      ),*/
    );
  }
}

class NewEventForm extends StatefulWidget {
  @override
  _NewEventState createState() {
    return _NewEventState();
  }
}

class _NewEventState extends State<NewEventForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> entries = <String>['A', 'B', 'C'];
  Iterable<Contact> _contacts;

  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.both;
  bool editable = true;
  DateTime date;

  @override
  initState() {
    super.initState();
    refreshContacts();
  }

  refreshContacts() async {
    var contacts = await ContactsService.getContacts();
//      var contacts = await ContactsService.getContactsForPhone("8554964652");
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Event name',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter some text';
                }
                return null;
              },
            ),
            DateTimePickerFormField(
              inputType: inputType,
              format: formats[inputType],
              editable: editable,
              decoration: InputDecoration(
                  labelText: 'Date/Time', hasFloatingPlaceholder: false),
              onChanged: (dt) => setState(() => date = dt),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 50,
                    child: participantCard(entries[index]),
                  );
                },
              ),
            ),
            FloatingActionButton.extended(
              onPressed: () {
                _displayDialog(context);
                //TODO: Add function to add participants to list
              },
              label: Text('Add participants'),
              tooltip: 'Add participants to event',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState.validate()) {
                    // Process data.
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget participantCard(String name) {
    return Card(child: ListTile(title: Text(name)));
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('ListView in Dialog'),
            content: Container(
              width: double.maxFinite,
              height: 300.0,
              child: ListView(
                padding: EdgeInsets.all(8.0),
                //map List of our data to the ListView
                children:
                    _contacts.map((data) => Text(data.initials())).toList(),
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

}

/*class ContactsDialog extends StatefulWidget {
  @override
  _ContactsDialogState createState() {
    return _ContactsDialogState();
  }
}

class _ContactsDialogState extends State<NewEventForm> {

  @override
  Widget build(BuildContext context) {
    return
  }

}*/
