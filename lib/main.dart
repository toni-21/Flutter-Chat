import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './login_dialog.dart';
import './model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import './home.dart';
import './Lobby.dart';
import './create_room.dart';
import './room.dart';
import './user_list.dart';

var exists;
var credentials;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    model.docsDir = docsDir;
    var credentialsFile = File(join(model.docsDir!.path, "credentials"));
    exists = await credentialsFile.exists();

    if (exists) {
      credentials = await credentialsFile.readAsString();
      print("## main(): credentials = $credentials");
      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
      model.setGreeting("Welcome back ${credParts[0]}");
    }

    runApp(FlutterChat());
  }

  startMeUp();
}

class FlutterChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: FlutterChatMain()));
  }
}

class FlutterChatMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    model.rootBuildContext = context;
    WidgetsBinding.instance!.addPostFrameCallback((_) => executeAfterBuild());
    return ScopedModel<ChatModel>(
        model: model,
        child: ScopedModelDescendant<ChatModel>(
            builder: (BuildContext context, Widget? child, ChatModel model) {
          return MaterialApp(
            initialRoute: "/",
            routes: {
              "/Lobby": (screenContext) => Lobby(),
              "/Room": (screenContext) => Room(),
              "/UserList": (screenContext) => UserList(),
              "/CreateRoom": (screenContext) => CreateRoom(),
            },
            home: Home(),
          );
        }));
  }

  Future<void> executeAfterBuild() async {
    if (!exists) {
      await showDialog(
          context: model.rootBuildContext!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return LoginDialog();
          });
    }
  }
}
