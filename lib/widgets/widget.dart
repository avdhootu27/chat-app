import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context){
  return AppBar(
    title: Text('Flutter chat app'),
  );
}

InputDecoration textFieldInputDecoration(String hint){
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: Colors.white.withOpacity(0.7),
    ),
    contentPadding: EdgeInsets.only(top: 0,bottom: 0,left: 10),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: Colors.blue),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: BorderSide(color: Colors.white),
    )
  );
}

TextStyle simpleTextFieldStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 14,
  );
}

TextStyle mediumTextFieldStyle() {
  return TextStyle(
    color: Colors.white,
  );
}