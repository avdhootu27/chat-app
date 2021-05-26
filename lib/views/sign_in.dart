import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chat_row.dart';

class SignIn extends StatefulWidget {

  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  QuerySnapshot userInfoSnapshot;
  String message;
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  signMeIn() async {
    if(formKey.currentState.validate()){
      setState(() {
        _isLoading = true;
      });
      String name;
      String email = emailTextEditingController.text;
      await authMethods.signInWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text).then((user){
        if(user == 88.25){
          setState(() {
            message = 'No user found for this email';
            _isLoading = false;
          });
        }
        else if(user == 88.26){
          setState(() {
            message = 'Wrong password';
            _isLoading = false;
          });
        }
        else if(user == 88.27){
          setState(() {
            message = "Couldn't Sign in";
            _isLoading = false;
          });
        }
        else if(user != null){
          databaseMethods.getUserByUserEmail(email).then((val){
            userInfoSnapshot = val;
            if(userInfoSnapshot != null){
              name = userInfoSnapshot.docs[0].data()['name'];
              Constants.myName = name;
              Constants.myEmail = email;
              HelperFunctions.saveUserLoggedInSharedPref(true);
              HelperFunctions.saveUserEmailSharedPref(email);
              HelperFunctions.saveUserNameSharedPref(name);
              HelperFunctions.saveUserProfilePicSharedPref('none');
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => ChatRow(),
              ));
            }
          });
        }
      });
    }
  }

  signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    await authMethods.signInWithGoogle(context);
  }

  forgetPassword() async {
    await authMethods.resetPassword(emailTextEditingController.text);
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(5)),
            content: SingleChildScrollView(
              child: Text('Password reset email is sent to given email address.'),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : Container(
        height: MediaQuery.of(context).size.height ,
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          child: Container(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(                                        // email
                            validator: (val) {
                              if(val.isEmpty){
                                return "Please enter email";
                              }
                              return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val) ? null : "Enter correct email";
                            },
                            controller: emailTextEditingController,
                            style: mediumTextFieldStyle(),
                            decoration: textFieldInputDecoration('Email'),
                          ),
                          SizedBox(height: 10,),
                          TextFormField(                                        // password
                            validator: (val) {
                              if(val.isEmpty){
                                return "Please enter password";
                              }
                              else if(val.length < 6){
                                return "Password must be of at least 6 characters";
                              }
                              return null;
                            },
                            obscureText: true,
                            controller: passwordTextEditingController,
                            style: mediumTextFieldStyle(),
                            decoration: textFieldInputDecoration('Password'),
                          ),
                          message != null ? Container(                          // message
                            child: Column(
                              children: [
                                SizedBox(height: 10,),
                                Center(child: Text(message,style: TextStyle(color: Colors.red),)),
                                SizedBox(height: 10),
                              ],
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                    SizedBox(height: 4,),
                    Container(                                                  // forgot password
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailTextEditingController.text)){
                            forgetPassword();
                          }
                          else{
                            setState(() {
                              message = "Enter correct email";
                            });
                        }
                        },
                        child: Text('Forgot Password ?',style: mediumTextFieldStyle(),),
                      ),
                    ),
                    SizedBox(height: 8,),
                    GestureDetector(                                            // sign in button
                      onTap: () {
                        signMeIn();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xff007EF4),
                              const Color(0xff2A75BC),
                            ]
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text("Sign In", style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),),
                      ),
                    ),
                    // SizedBox(height: 11,),
                    Row(children: <Widget>[
                      Expanded(
                        child: new Container(
                            margin: const EdgeInsets.only(left: 0, right: 10),
                            child: Divider(
                              color: Colors.white,
                              height: 50,
                            )),
                      ),
                      Text("OR", style: TextStyle(
                        color: Colors.white,
                      ),),
                      Expanded(
                        child: new Container(
                            margin: const EdgeInsets.only(left: 10, right: 0),
                            child: Divider(
                              color: Colors.white,
                              height: 50,
                            )),
                      ),
                    ]),
                    GestureDetector(                                            // sign in with google button
                      onTap: () {
                        signInWithGoogle();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text("Sign In with Google", style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),),
                      ),
                    ),
                    SizedBox(height: 50,),
                    Row(                                                        // don't have account
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have account?",
                          style: simpleTextFieldStyle(),
                        ),
                        TextButton(
                          onPressed: () {
                            widget.toggle();
                          },
                          child: Text('Register now', style: simpleTextFieldStyle()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }
}
