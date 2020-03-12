library json_form_generator;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class JsonFormGenerator extends StatefulWidget {
  final String form;
  final ValueChanged<dynamic> onChanged;

  JsonFormGenerator({
    @required this.form,
    @required this.onChanged,
  });
  @override
  _JsonFormGeneratorState createState() =>
      _JsonFormGeneratorState(json.decode(form));
}

class _JsonFormGeneratorState extends State<JsonFormGenerator> {
  final dynamic formItems;
  _JsonFormGeneratorState(this.formItems);
  void _handleChanged() {
    widget.onChanged(formResults);
  }

  final Map<String, dynamic> formResults = {};

  Map<String, dynamic> radioValueMap = {};
  Map<String, String> dropDownMap = {};
  Map<String, String> _datevalueMap = {};
  Map<String, bool> switchValueMap = {};

  void updateSwitchValue(dynamic itme, bool value) {
    setState(() {
      switchValueMap[itme] = value;
    });
  }

  List<Widget> jsonToForm() {
    List<Widget> listWidget = new List<Widget>();

    for (var item in formItems) {
      if (item['type'] == 'text' ||
          item['type'] == 'integer' ||
          item['type'] == "password" ||
          item['type'] == "multiline") {
        listWidget.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            child: TextFormField(
              autofocus: false,
              onChanged: (String value) {
                formResults[item["title"]] = value;
                _handleChanged();
              },
              inputFormatters: item['type'] == 'integer'
                  ? [WhitelistingTextInputFormatter(RegExp('[0-9]'))]
                  : null,
              keyboardType:
                  item['type'] == 'integer' ? TextInputType.number : null,
              validator: (String value) {
                if (item['required'] == 'no') {
                  return null;
                }
                if (value.isEmpty) {
                  return 'Please ${item['title']} cannot be empty';
                }
                return null;
              },
              maxLines: item['type'] == "multiline" ? 10 : 1,
              obscureText: item['type'] == "password" ? true : false,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                labelText: item['label'],
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
          ),
        );
      }
      if (item['type'] == 'select') {
        var newlist = List<String>.from(item['enum']);

        listWidget.add(Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            hint: Text('Select ${item['title']}'),
            validator: (String value) {
              if (item['required'] == 'no') {
                return null;
              }
              if (value == null) {
                return 'Please ${item['title']} cannot be empty';
              }
              return null;
            },
            value: dropDownMap[item["title"]],
            isExpanded: true,
            style: Theme.of(context).textTheme.subhead,
            onChanged: (String newValue) {
              setState(() {
                dropDownMap[item["title"]] = newValue;
                formResults[item["title"]] = newValue.trim();
              });
            },
            items: newlist.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ));
      }

      if (item['type'] == 'date') {
        Future _selectDate() async {
          DateTime picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1880),
            lastDate: DateTime(2021),
            builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light(),
                child: child,
              );
            },
          );
          if (picked != null)
            setState(() => _datevalueMap[item["title"]] =
                picked.toString().substring(0, 10));
          print(_datevalueMap[item['title']]);
        }

        listWidget.add(
          Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextFormField(
                autofocus: false,
                readOnly: true,
                controller:
                    TextEditingController(text: _datevalueMap[item["title"]]),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Please  cannot be empty';
                  }
                  return null;
                },
                onChanged: (String value) {
                  print("object");
                },
                onTap: () async {
                  await _selectDate();
                  formResults[item["title"]] =
                      _datevalueMap[item["title"]].trim();
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  labelText: item["label"],
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  suffixIcon: Icon(
                    Icons.calendar_today,
                  ),
                ),
              )),
        );
      }

      if (item['type'] == 'radio') {
        radioValueMap["${item["title"]}"] =
            radioValueMap["${item["title"]}"] == null
                ? 'lost'
                : radioValueMap["${item["title"]}"];

        listWidget.add(new Container(
            margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: new Text(item['label'],
                style: new TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16.0))));

        for (var i = 0; i < item['items'].length; i++) {
          listWidget.add(
            new Row(
              children: <Widget>[
                new Expanded(child: new Text(item['items'][i])),
                new Radio<dynamic>(
                    hoverColor: Colors.red,
                    value: item['items'][i],
                    groupValue: radioValueMap["${item["title"]}"],
                    onChanged: (dynamic value) {
                      print(value);
                      setState(() {
                        radioValueMap["${item["title"]}"] = value;
                      });
                      formResults[item["title"]] = value;

                      _handleChanged();
                    })
              ],
            ),
          );
        }
      }

      if (item['type'] == 'switch') {
        if (switchValueMap["${item["title"]}"] == null) {
          formResults[item["title"]] = false;
          setState(() {
            switchValueMap["${item["title"]}"] = false;
          });
        }
        listWidget.add(Row(
          children: <Widget>[
            new Expanded(child: new Text(item["label"])),
            Switch(
                value: switchValueMap["${item["title"]}"],
                onChanged: (bool value) {
                  updateSwitchValue(item["title"], value);
                  formResults[item["title"]] = value;
                  _handleChanged();
                }),
          ],
        ));
      }
    }
    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.all(30),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: jsonToForm(),
      ),
    );
  }
}
