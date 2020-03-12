import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:json_form_generator/json_form_generator.dart';

class Reg extends StatefulWidget {
  @override
  _RegState createState() => _RegState();
}

class _RegState extends State<Reg> {
  dynamic response;
  var _formkey = GlobalKey<FormState>();

  String form = json.encode([
    {
      'title': 'switchtext',
      'type': 'switch',
      'label': 'Radio Button tests',
    },
    {
      'title': 'switch',
      'type': 'switch',
      'label': 'Radio Button tests 2',
    },
    {
      'title': 'radiotest',
      'type': 'radio',
      'label': 'Radio Button tests',
      'items': ["product 1", "product 2", "product 3"],
    },
    {
      'title': 'ratio',
      'type': 'radio',
      'label': 'Radio Button tests',
      'items': ["House", "Food", "Ass"],
    },
    {
      "title": "name",
      "label": "what is your name",
      "type": "text",
      "required": "yes"
    },
    {
      "title": "dateOfReg",
      "label": "what is the date of registration",
      "type": "date",
      "required": "no"
    },
    {
      "title": "agegroup",
      "label": "tell us your age group",
      "type": "select",
      "items": ["1-20", "21-30", "31-40", "41-50", "51-60"],
      "required": "no"
    }
  ]);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JSON FORM GEN"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(children: <Widget>[
            JsonFormGenerator(
              form: form,
              onChanged: (dynamic value) {
                print(value);
                setState(() {
                  this.response = value;
                });
              },
            ),
            new RaisedButton(
                child: new Text('Send'),
                onPressed: () {
                  if (_formkey.currentState.validate()) {
                    print(this.response.toString());
                  }
                })
          ]),
        ),
      ),
    );
  }
}
