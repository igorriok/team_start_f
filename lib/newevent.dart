import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

class NewEventPage extends StatelessWidget {

  //TODO: Change the root widget to listview
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

  Iterable<Contact> contacts;
  final formKey = GlobalKey<FormState>();
  final format = DateFormat("yyyy-MM-dd HH:mm");

  /*@override
  void initState() {
    super.initState();
    getContacts().then((value){
      contacts = value;
      print('Loaded ' + value.length.toString() + ' contacts');
    });
  }*/

  Future<Iterable<Contact>> getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    //print("Contact: " + cont.length.toString());
    return contacts;
  }

  Future<List<String>> getEmails(text) async {
    //TODO: Iterate Contacts names and find which match the pattern
    //TODO: Return only emails of this contacts
    return contacts.where((contact) => contact.givenName.contains(text) | contact.familyName.contains(text))
        .expand((contact) => contact.emails.map((email) => email.value)).toList();
  }

  int entries = 1;

  void _addField() {
    setState(() {
      entries++;
    });
  }

  Map<int, String> guestList = Map<int, String>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: formKey,
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
                    firstDate: DateTime(2019),
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
                  return ParticipantField(index: index, /*contacts: contacts,*/ addGuest: (guest) {
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
                  if (formKey.currentState.validate()) {
                    // Process data.
                    this.formKey.currentState.save();
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

  ParticipantField({Key key, @required this.index, /*@required this.contacts,*/
    @required this.addGuest}) : super(key: key);

  final int index;
  final ValueChanged<String> addGuest;
  /*final Iterable<Contact> contacts;*/

  @override
  _ParticipantFieldState createState() => _ParticipantFieldState();
}

class _ParticipantFieldState extends State<ParticipantField> {

  Iterable<Contact> contacts;
  GlobalKey key = new GlobalKey<AutoCompleteTextFieldState<Contact>>();

  _ParticipantFieldState() {
    getContacts().then((val) => setState(() {
      contacts = val;
    }));
  }

  Future<List<Contact>> getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    print("Contact: " + contacts.toList().length.toString());
    return contacts.toList();
  }

  /*
  Future<List<String>> getEmails(text) async {
    //TODO: Iterate Contacts names and find which match the pattern
    //TODO: Return only emails of this contacts
    return widget.contacts.where((contact) => contact.givenName.contains(text) | contact.familyName.contains(text))
        .expand((contact) => contact.emails.map((email) => email.value)).toList();
  }*/

  void _handleSave(String value) {
    widget.addGuest(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: AutoCompleteTextField<Contact>(
        key: key,
        clearOnSubmit: false,
        suggestions: contacts,
        style: TextStyle(color: Colors.black, fontSize: 16.0),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
          hintText: "Search Name",
          hintStyle: TextStyle(color: Colors.black),
        ),
        itemFilter: (item, query) {
          return item.familyName
              .toLowerCase()
              .startsWith(query.toLowerCase());
        },
        itemSorter: (a, b) {
          return a.givenName.compareTo(b.givenName);
        },
        itemSubmitted: (item) {
          _handleSave(item.givenName);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
              title: new Text(suggestion.givenName),
          );
        }
      ),
    );
  }
}

