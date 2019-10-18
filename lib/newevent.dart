import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class NewEventPage extends StatelessWidget {

  //TODO: Create a JSON
  //TODO: Send JSON to DB
  //TODO: Close this page

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
  _NewEventState createState() => _NewEventState();
}

class _NewEventState extends State<NewEventForm> {
  final _formKey = GlobalKey<FormState>();
  int entries = 1;
  Iterable<Contact> _contacts;

  final format = DateFormat("yyyy-MM-dd HH:mm");

  Future<List<String>> getContacts(pattern) async {
    Iterable<Contact> cont = await ContactsService.getContacts(query : pattern);
    //print("Contact: " + cont.toString());
    return cont.expand((contact) => contact.emails.map((email) => email.value)).toList();
  }

  void _addField() {
    setState(() {
      entries++;
    });
  }

  Map<int, String> guestList = Map<int, String>();

  void _addGuest(int key, String email) {
    setState(() {
      guestList.putIfAbsent(key, () => email);
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
            DateTimeField(
              format: format,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Event time',
              ),
              onShowPicker: (context, currentValue) async {
                final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime:
                    TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  return DateTimeField.combine(date, time);
                } else {
                  return currentValue;
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemCount: entries,
                itemBuilder: (context, int index) {
                  return ParticipantField(index: index, addGuest: (guest) {
                    guestList.putIfAbsent(index, () => guest);
                    print(guestList);
                  });
                },
              ),
            ),
            FloatingActionButton.extended(
              onPressed: () {
                _addField();
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
                    this._formKey.currentState.save();
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

}

class ParticipantField extends StatefulWidget {

  ParticipantField({Key key, @required this.index, @required this.addGuest}) : super(key: key);

  final int index;
  final ValueChanged<String> addGuest;

  @override
  _ParticipantFieldState createState() => _ParticipantFieldState();
}

class _ParticipantFieldState extends State<ParticipantField> {

  Future<List<String>> getContacts(pattern) async {
    Iterable<Contact> cont = await ContactsService.getContacts(query : pattern);
    //print("Contact: " + cont.toString());
    return cont.expand((contact) => contact.emails.map((email) => email.value)).toList();
  }

  final TextEditingController _typeAheadController = TextEditingController();

  void _handleSave(String value) {
    widget.addGuest(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: TypeAheadFormField(
        textFieldConfiguration: TextFieldConfiguration(
            controller: _typeAheadController,
            decoration: InputDecoration(
              labelText: "Participant: " + (widget.index+1).toString(),
            )
        ),
        suggestionsCallback: (pattern) async {
          print("sugetion");
          return await getContacts(pattern);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        transitionBuilder: (context, suggestionsBox, controller) {
          return suggestionsBox;
        },
        onSuggestionSelected: (suggestion) {
          this._typeAheadController.text = suggestion;
        },
        // TODO: Check how to save the form (how to trigger this callback)
        onSaved: (value) => this._handleSave(value),
      ),
    );
  }
}

