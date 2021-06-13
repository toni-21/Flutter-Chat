import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './model.dart';
import './app_drawer.dart';

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: model,
        child: ScopedModelDescendant<ChatModel>(
            builder: (BuildContext context, Widget? child, ChatModel model) {
          return Scaffold(
            drawer: AppDrawer(),
            appBar: AppBar(title: Text("User List")),
            body: GridView.builder(
              itemCount: model.userList.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                Map user = model.userList[index];
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: GridTile(
                        child: Center(
                          child: Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Image.asset("assets/user.png")),
                        ),
                        footer: Text(
                          user["userName"],
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }));
  }
}
