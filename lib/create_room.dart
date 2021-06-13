import 'package:flutter/material.dart';
import 'package:flutter_chat/connector.dart';
import 'package:scoped_model/scoped_model.dart';
import './model.dart';
import './app_drawer.dart';

class CreateRoom extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateRoomState();
  }
}

class _CreateRoomState extends State<CreateRoom> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    "title": null,
    "description": null,
    "private": false,
    "maxPeople": 25,
  };

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: model,
        child: ScopedModelDescendant<ChatModel>(
            builder: (BuildContext context, Widget? child, ChatModel model) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: Text("CreateRoom")),
            drawer: AppDrawer(),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: SingleChildScrollView(
                  child: Row(children: <Widget>[
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    Navigator.of(context).pop();
                  },
                ),
                Spacer(),
                TextButton(
                  child: Text("Save"),
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _formKey.currentState!.save();

                    create(
                        _formData["title"],
                        _formData["description"],
                        _formData["maxPeople"].toString(),
                        _formData["private"],
                        model.userName);
                    if (model.status == "create:created") {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                        content: Text("Sorry, that room already exists"),
                      ));
                    }
                  },
                ),
              ])),
            ),
            body: Form(
                key: _formKey,
                child: ListView(children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(labelText: "Name"),
                      validator: (String? value) {
                        if (value == null || value.length > 14) {
                          return " Please enter a room name no more than 14 characters long";
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        setState(() {
                          _formData["title"] = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      decoration: InputDecoration(labelText: "Description"),
                      onSaved: (String? value) {
                        setState(() {
                          _formData["description"] = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Text("Max\nPeople"),
                        Slider(
                          min: 0,
                          max: 99,
                          value: _formData["maxPeople"],
                          onChanged: (double value) {
                            setState(() {
                              _formData["maxPeople"] = value.truncate();
                            });
                          },
                        )
                      ],
                    ),
                    trailing: Text("${_formData["maxPeople"]}"),
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Text("Private"),
                        Switch(value: _formData["private"], onChanged: (value){
                          setState(() {
                            _formData["private"] = value;
                          });
                        }),
                      ],
                    ),
                  ),
                ])),
          );
        }));
  }
}
