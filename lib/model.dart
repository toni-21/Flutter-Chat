import 'dart:io';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

class ChatModel extends Model {
  BuildContext? rootBuildContext;
  Directory? docsDir;
  String? status;
  String? greeting;
  String userName = "";
  static final String defaultRoomName = "Not currently in a room";
  String currentRoomName = defaultRoomName;
  List currentRoomUserList = [];
  bool currentRoomEnabled = false;
  List currentRoomMessages = [];
  List roomList = [];
  List userList = [];
  bool creatorFunctionsEnabled = false;
  Map roomInvites = {};

  void setGreeting(String inGreeting) {
    greeting = inGreeting;
    notifyListeners();
    print("## ChatModel.setGreeting(): inGreeting = $inGreeting");
  }

  void setUserName(String inUserName) {
    userName = inUserName;
    notifyListeners();
  }

  void setStatus(String inStatus) {
    status = inStatus;
    notifyListeners();
  }

  void setRoomName(String inRoomName) {
    currentRoomName = inRoomName;
    notifyListeners();
  }

  void setCreatorFunctionEnabled(bool inEnabled) {
    creatorFunctionsEnabled = inEnabled;
    notifyListeners();
  }

  void setCurrentRoomEnabled(bool inEnabled) {
    currentRoomEnabled = inEnabled;
    notifyListeners();
  }

  void addmessage(String username, String message) {
    currentRoomMessages.add({"userName": username, "message": message});
    notifyListeners();
  }

  void setRoomList(Map inRoomList) {
    List rooms = [];
    for (String roomName in inRoomList.keys) {
      Map room = inRoomList[roomName];
      rooms.add(room);
    }
    roomList = rooms;
    notifyListeners();
  }

  void setUserList(Map inUserList) {
    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }
    userList = users;
    print("current UserList: $userList");
    notifyListeners();
  }

  void setCurrentRoomUserList(Map inUserList) {
    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }
    currentRoomUserList = users;
    notifyListeners();
  }

  void addRoomInvite(String inRoomName) {
    roomInvites[inRoomName] = true;
    notifyListeners();
  }

  void removeRoomInvite(String inRoomName) {
    roomInvites.remove(inRoomName);
    notifyListeners();
  }

  void clearCurrentMessages() {
    currentRoomMessages = [];
    notifyListeners();
  }
}

ChatModel model = ChatModel();
