import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import './model.dart';

Socket socket = io('http://localhost:3000', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});

String? status;
// ------------------------------ NONE-MESSAGE RELATED METHODS ------------------------------
void showPleaseWait() {
  print("Connector.showPleaseWait");

  showDialog(
      context: model.rootBuildContext!,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          width: 150,
          height: 150,
          alignment: AlignmentDirectional.center,
          decoration: BoxDecoration(color: Colors.blue[200]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: 10,
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                      child: Text("Please wait, contacting the server...")))
            ],
          ),
        ));
      });
}

void hidePleaseWait() {
  print("Connector.hidePleaseWait");
  Navigator.of(model.rootBuildContext!).pop();
}

void connectToServer() {
  try {
    socket.connect();
    socket.onConnect((_) {
      print('connected: ${socket.id}');
    });
    socket.on("not", (arg) => print(arg));
    socket.on("status", (arg) {
      model.setStatus(arg);
      status = arg.toString();
      print(status); 
    });
    socket.on("newUser", newUser);
    socket.on("created", created);
    socket.on("invited", invited);
    socket.on("joined", joined);
    socket.on("left", left);
    socket.on("posted", posted);
    socket.on("closed", closed);
    socket.on("kicked", kicked);
    socket.on("allUsers", allUsers);
    socket.on("allRooms", allRooms);
    socket.onDisconnect((_) => print('disconnect'));
  } catch (e) {
    print("this is the server error: === ${e.toString()}");
  }
}

// ------------------------------ MESSAGE SENDER METHODS ------------------------------

void validate(String userName, String password) {
  Map<String, dynamic> data = {"userName": userName, "password": password};

  socket.emit("validate", data);
}

void listRooms() {
  print(" Requesting list of rooms...");
  socket.emit("listRooms", {});
}

void listUsers() {
  print(" Requesting list of users...");
  socket.emit("listUsers", {});
}

void create(String roomName, String description, String maxPeople, bool private,
    String creator) {
  print(
      "## Connector.create(): inRoomName = $roomName, inDescription = $description, "
      "inMaxPeople = $maxPeople, inPrivate = $private, inCreator = $creator");
  Map<String, dynamic> data = {
    "roomName": roomName,
    "description": description,
    "maxPeople": maxPeople,
    "private": private.toString(),
    "creator": creator
  };
  socket.emit("create", data);
}

void joinRoom(String userName, String roomName) {
  print("## Connector.join(): userName= $userName roomName= $roomName");
  Map<String, dynamic> data = {"userName": userName, "roomName": roomName};
  socket.emit("join", data);
}

void leave(String userName, String roomName) {
  print("## Connector.leave(): userName= $userName roomName= $roomName");
  Map<String, dynamic> data = {"userName": userName, "roomName": roomName};
  socket.emit("leave", data);
}

void post(String userName, String roomName, String message) {
  print(
      "## Connector.post(): userName= $userName roomName= $roomName message= $message");
  Map<String, dynamic> data = {
    "userName": userName,
    "roomName": roomName,
    "message": message
  };
  socket.emit("post", data);
}

void invite(String userName, String roomName, String inviterName) {
  print("## Connector.close(): roomName = $roomName");
  Map<String, dynamic> data = {
    "userName": userName,
    "roomName": roomName,
    "inviterName": inviterName
  };
  socket.emit("invite", data);
}

// -----CREATOR FUNCTIONS
void close(String roomName) {
  print("## Connector.close(): roomName = $roomName");
  Map<String, dynamic> data = {"roomName": roomName};
  socket.emit("close", data);
}

void kick(String userName, String roomName) {
  print("## Connector.kick(): userName = $userName  roomName = $roomName");
  Map<String, dynamic> data = {"userName": userName, "roomName": roomName};
  socket.emit("close", data);
}

// ------------------------------ MESSAGE RECEIVER METHODS ------------------------------
void allUsers(data) {
  print("Connector.allUsers(): data = $data");
  Map<String, dynamic> payload = data;
  model.setUserList(payload);
}

void allRooms(data) {
  print("Connector.allRooms(): data = $data");
  Map<String, dynamic> payload = data;
  model.setRoomList(payload);
}

void newUser(data) {
  print("Connector.newUser(): data = $data");
  Map<String, dynamic> payload = data;
  model.setUserList(payload);
}

void created(data) {
  print("Connector.created(): data = $data");
  Map<String, dynamic> payload = data;
  model.setRoomList(payload);
}

void joined(data) {
  print("Connector.joined(): data = $data");
  Map<String, dynamic> payload = data;

  if (model.currentRoomName == payload["roomName"]) {
    model.setCurrentRoomUserList(payload['users']);
  }
}

void invited(data) {
  print("Connector.invited(): data = $data");
  Map<String, dynamic> payload = data;

  String userName = payload["userName"];
  String roomName = payload["roomName"];
  String inviterName = payload["inviterName"];

  model.addRoomInvite(roomName);

  ScaffoldMessenger.of(model.rootBuildContext!).showSnackBar(
    SnackBar(
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 60),
      content: Text(
          "'$userName' has been invited to the room '$roomName' by '$inviterName'.\n\n"
          "You can enter the room from the lobby"),
      action: SnackBarAction(label: "Ok", onPressed: () {}),
    ),
  );
}

void left(data) {
  print("Connector.left(): data = $data");
  Map<String, dynamic> payload = data;

  if (model.currentRoomName == payload["room"]["roomName"]) {
    model.setCurrentRoomUserList(payload["room"]['users']);
  }
}

void posted(data) {
  print("Connector.post(): data = $data");
  Map<String, dynamic> payload = data;
  String username = payload["userName"];
  String message = payload["message"];
  if (model.currentRoomName == payload["roomName"]) {
    model.addmessage(username, message);
  }
}

void kicked(data) {
  print("Connector.kicked(): data = $data");
  Map<String, dynamic> payload = data;

  model.removeRoomInvite(payload['roomName']);
  model.setCurrentRoomUserList({});
  model.setRoomName(ChatModel.defaultRoomName);
  model.setCurrentRoomEnabled(false);

  model.setGreeting("What did you do? You got kicked from the room lol");
}

void closed(data) {
  print("Connector.closed(): data = $data");
  Map<String, dynamic> payload = data;

  model.setRoomList(payload["rooms"]);

  if (payload["roomName"] == model.currentRoomName) {
    model.removeRoomInvite(payload["roomName"]);
    model.setCurrentRoomUserList({});
    model.setRoomName(ChatModel.defaultRoomName);
    model.setCurrentRoomEnabled(false);

    model.setGreeting("The room you were in has been closed by its creator");
    //Toni remember to route back to the home screen!
  }
}
