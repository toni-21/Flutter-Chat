import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:path/path.dart';
import './model.dart';
import './connector.dart';

class LoginDialog extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _formData = {
    "username": null,
    "password": null,
  };

  void validateWithStoredCredentials(String userName, String password) {
    connectToServer();
    validate(userName, password);

    if (model.status == "validate:ok" || model.status == "validate:created") {
      model.setUserName(userName);
      model.setGreeting("Welcome back, $userName");
    } else if (model.status == "validate:fail") {
      showDialog(
          context: model.rootBuildContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Validation failed"),
              content: Text(
                  "It appears that the server has restarted and the username you last used was subsequently taken by someone else \nPlease re-start FlutterChat and choose a different username."),
              actions: [
                TextButton(
                    child: Text('Ok'),
                    onPressed: () {
                      var credentialsFile =
                          File(join(model.docsDir!.path, "credentials"));
                      credentialsFile.deleteSync();
                      exit(0);
                    })
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: model,
        child: ScopedModelDescendant<ChatModel>(
            builder: (BuildContext context, Widget? child, ChatModel model) {
          return AlertDialog(
            content: Container(
              height: 220,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Text(
                      "Enter a username and password to register to the server",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, color: Theme.of(context).accentColor),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Username", hintText: "Username"),
                      validator: (String? value) {
                        if (value == null || value.length > 10) {
                          return "Please enter a username no more than 10 characters long";
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        _formData["username"] = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: "Password", hintText: "Password"),
                      validator: (String? value) {
                        if (value == null) {
                          return "Please enter a password";
                        }
                        return null;
                      },
                      onSaved: (String? value) {
                        _formData["password"] = value;
                      },
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Log IN"),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  _formKey.currentState!.save();
                  connectToServer();
                  validate(_formData["username"], _formData["password"]);
                  print("status is: ${model.status}");
                  if (model.status == "validate:ok") {
                    model.setUserName(_formData["username"]);
                    Navigator.of(model.rootBuildContext!).pop();
                    model.setGreeting("Welcome back, ${_formData["username"]}");
                  } else if (model.status == "validate:fail") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        content: Text("Sorry that username is already taken"),
                      ),
                    );
                  } else if (model.status == "validate:created") {
                    var credentialsFile =
                        File(join(model.docsDir!.path, "credentials"));
                    credentialsFile.writeAsString(
                        "${_formData["username"]}============${_formData["password"]}");
                    model.setUserName(_formData["username"]);
                    Navigator.of(context).pop();
                    model.setGreeting(
                        "Welcome to the server, ${_formData["username"]}");
                  }
                },
              ),
            ],
          );
        }));
  }
}
