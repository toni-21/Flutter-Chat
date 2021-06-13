import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './model.dart';
import './app_drawer.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: model,
        child: ScopedModelDescendant<ChatModel>(
            builder: (BuildContext context, Widget? child, ChatModel model) {
          return Scaffold(
            appBar: AppBar(
              title: Text("FlutterChat"),
            ),
            drawer: AppDrawer(),
            body: Center(
              child: Text("${model.greeting}"),
            ),
          );
        }));
  }
}
