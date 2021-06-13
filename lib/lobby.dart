import 'package:flutter/material.dart';
import 'connector.dart';
import 'package:scoped_model/scoped_model.dart';
import 'model.dart';
import './app_drawer.dart';

class Lobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
        model: model,
        child: ScopedModelDescendant<ChatModel>(
            builder: (BuildContext context, Widget? child, ChatModel model) {
          return Scaffold(
              appBar: AppBar(title: Text("Lobby")),
              drawer: AppDrawer(),
              floatingActionButton: FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed("/CreateRoom");
                },
              ),
              body: model.roomList.length == 0
                  ? Center(
                      child: Text("There are no rooms yet. Why not add one?"),
                    )
                  : ListView.builder(
                      itemCount: model.roomList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map _room = model.roomList[index];
                        String _roomName = _room["roomName"];
                        String _description = _room["description"];
                        bool _isPrivate = _room["private"];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              leading: _isPrivate
                                  ? Image.asset("assets/private.png")
                                  : Image.asset("assets/public.png"),
                              title: Text(_roomName),
                              subtitle: Text(_description),
                              onTap: () {
                                if (_isPrivate &&
                                    !model.roomInvites.containsKey(_roomName) &&
                                    _room["creator"] != model.userName) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                    content: Text(
                                        "Sorry you can't enter a private room without an invite"),
                                  ));
                                } else {
                                  joinRoom(model.userName, _roomName);
                                  if (model.status == "join:joined") {
                                    model.setCurrentRoomEnabled(true);
                                    model.clearCurrentMessages();
                                    if (_room["creator"] == model.userName) {
                                      model.setCreatorFunctionEnabled(true);
                                    } else {
                                      model.setCreatorFunctionEnabled(false);
                                    }
                                    Navigator.pushNamed(context, "/Room");
                                  } else if (model.status == "join:full") {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                      content: Text("Sorry, that room is full"),
                                    ));
                                  }
                                }
                              },
                            )
                          ],
                        );
                      }));
        }));
  }
}
