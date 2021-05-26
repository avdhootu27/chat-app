import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/views/chat_row.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool userLoggedIn;

  @override
  void initState() {
    super.initState();
    getLoggedInState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedInSharedPref().then((val){
      setState(() {
        userLoggedIn = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xff145C9E),
        scaffoldBackgroundColor: Color(0xff1F1F1F),
      ),
      home: userLoggedIn != null ? (userLoggedIn ? ChatRow() : Authenticate()) : Blank(),
    );
  }
}

class Blank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}


// 20 May 2021, 8:36 PM -> 2146 lines