import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './model.dart';
import './connector.dart';
import './app_drawer.dart';

class Room extends StatefulWidget {
  Room({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _RoomState();
  }
}

class _RoomState extends State<Room> {
  bool _expanded = false;
  String? _postMessage;
  final ScrollController _controller = ScrollController();
  final TextEditingController _postEditingController = TextEditingController();

  void _inviteOrKick(BuildContext context, String action) {
    listUsers();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ScopedModel(
              model: model,
              child: ScopedModelDescendant<ChatModel>(builder:
                  (BuildContext context, Widget? child, ChatModel model) {
                return AlertDialog(
                  title: Text("Select user to $action"),
                  content: Container(
                    width: double.maxFinite / 2,
                    child: ListView.builder(
                        itemCount: action == "invite"
                            ? model.userList.length
                            : model.currentRoomUserList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map user;
                          if (action == "invite") {
                            user = model.userList[index];
                          } else {
                            user = model.currentRoomUserList[index];
                          }
                          if (user["userName"] == model.userName) {
                            return Container();
                          }
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                                border: Border(
                                    bottom: BorderSide(),
                                    top: BorderSide(),
                                    left: BorderSide(),
                                    right: BorderSide()),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    stops: [
                                      .1,
                                      .2,
                                      .3,
                                      .4,
                                      .5,
                                      .6,
                                      .7,
                                      .8,
                                      .9
                                    ],
                                    colors: [
                                      Color.fromRGBO(250, 250, 0, .75),
                                      Color.fromRGBO(250, 220, 0, .75),
                                      Color.fromRGBO(250, 190, 0, .75),
                                      Color.fromRGBO(250, 160, 0, .75),
                                      Color.fromRGBO(250, 130, 0, .75),
                                      Color.fromRGBO(250, 110, 0, .75),
                                      Color.fromRGBO(250, 80, 0, .75),
                                      Color.fromRGBO(250, 50, 0, .75),
                                      Color.fromRGBO(250, 0, 0, .75)
                                    ])),
                            margin: EdgeInsets.only(top: 10.0),
                            child: ListTile(
                              title: Text(user["userName"]),
                              onTap: () {
                                if (action == "invite") {
                                  invite(user["userName"],
                                      model.currentRoomName, model.userName);
                                  Navigator.of(context).pop();
                                } else {
                                  kick(user["userName"], model.currentRoomName);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          );
                        }),
                  ),
                );
              }));
        });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: ScopedModelDescendant<ChatModel>(
          builder: (BuildContext context, Widget? child, ChatModel model) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          drawer: AppDrawer(),
          appBar: AppBar(
            title: Text(model.currentRoomName),
            actions: [
              PopupMenuButton(onSelected: (value) {
                if (value == "invite") {
                  _inviteOrKick(context, "invite");
                } else if (value == "leave") {
                  leave(model.userName, model.currentRoomName);
                  model.removeRoomInvite(model.currentRoomName);
                  model.setRoomName(ChatModel.defaultRoomName);
                  model.setCurrentRoomEnabled(false);
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                } else if (value == "close") {
                  close(model.currentRoomName);
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                } else if (value == "kick") {
                  _inviteOrKick(context, "kick");
                }
              }, itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem(value: "leave", child: Text("Leave a Room")),
                  PopupMenuItem(value: "invite", child: Text("Invite a User")),
                  PopupMenuDivider(),
                  PopupMenuItem(
                      value: "close",
                      child: Text("Close a Room"),
                      enabled: model.creatorFunctionsEnabled),
                  PopupMenuItem(
                      value: "kick",
                      child: Text("Kick a User"),
                      enabled: model.creatorFunctionsEnabled),
                ];
              })
            ],
          ),
          body: Container(
              padding: EdgeInsets.fromLTRB(6, 14, 6, 6),
              child: Column(children: <Widget>[
                ExpansionPanelList(
                  expansionCallback: (int index, bool expanded) {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  children: <ExpansionPanel>[
                    ExpansionPanel(
                      isExpanded: _expanded,
                      headerBuilder: (BuildContext context, bool isExpanded) =>
                          Text("  Users in Room"),
                      body: Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Builder(
                          builder: (BuildContext context) {
                            List<Widget> userList = [];
                            for (var user in model.currentRoomUserList) {
                              userList.add(Text(user["userName"]));
                            }
                            return Column(
                              children: userList,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Container(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: model.currentRoomMessages.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map message = model.currentRoomMessages[index];
                      return ListTile(
                        subtitle: Text(message["userName"]),
                        title: Text(message["message"]),
                      );
                    },
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: _postEditingController,
                        decoration: InputDecoration.collapsed(
                            hintText: "Enter Message"),
                        onChanged: (String? text) {
                          setState(() {
                            _postMessage = text;
                          });
                        },
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            //This is the post function! Toni remember to make it like whatsapp
                            if (_postMessage == null) {
                              return;
                            } else {
                              post(model.userName, model.currentRoomName,
                                  _postMessage!);
                            }
                            if (model.status == "post:ok") {
                              _controller
                                  .jumpTo(_controller.position.maxScrollExtent);
                            }
                          },
                        )),
                  ],
                )
              ])),
        );
      }),
    );
  }
}
