import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './model.dart';
import './connector.dart';
import 'package:path/path.dart';
import 'dart:io';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: model,
        child: ScopedModelDescendant<ChatModel>(
            builder: (BuildContext context, Widget? child, ChatModel model) {
          return Drawer(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage("assets/drawback01.jpg"),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 15),
                    child: ListTile(
                      title: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Center(
                          child: Text(
                            model.userName,
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      subtitle: Center(
                        child: Text(model.currentRoomName,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text("Lobby"),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "/Lobby", ModalRoute.withName("/"));
                      connectToServer();
                      listRooms();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: ListTile(
                    leading: Icon(Icons.forum),
                    title: Text("Current Room"),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "/Room", ModalRoute.withName("/"));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: ListTile(
                    leading: Icon(Icons.face),
                    title: Text("User List"),
                    onTap: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          "/UserList", ModalRoute.withName("/"));
                      listUsers();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Logout"),
                    onTap: () async {
                      var credentialsFile =
                          File(join(model.docsDir!.path, "credentials"));
                      bool exists = await credentialsFile.exists();
                      if (exists) {
                        credentialsFile.deleteSync();
                        Navigator.of(context).popAndPushNamed("/");
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }));
  }
}
