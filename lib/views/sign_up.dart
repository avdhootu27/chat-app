import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_row.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {

  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String message;
  TextEditingController usernameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  AuthMethods authMethds = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  HelperFunctions helperFunctions = new HelperFunctions();

  signMeUp() async {
    if(formKey.currentState.validate()){
      String name = usernameTextEditingController.text;
      String email = emailTextEditingController.text;

      setState(() {
        isLoading = true;
      });

      dynamic available = await authMethds.userNameAvailable(name);
      if(!available){
        setState(() {
          message = 'Username not available';
          isLoading = false;
        });
        return;
      }

      authMethds.signUpWithEmailAndPassword(emailTextEditingController.text, passwordTextEditingController.text).then((user){
        if(user == 88.25){
          setState(() {
            message = 'Password is too weak';
            isLoading = false;
          });
        }
        else if(user == 88.26){
          setState(() {
            message = 'The account already exists';
            isLoading = false;
          });
        }
        else if(user != null){
          Map<String,String> userInfoMap = {
            'name' : name,
            'email' : email,
            'imgUrl' : 'none',
          };
          databaseMethods.uploadUserInfo(name, userInfoMap);
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
        else {
          setState(() {
            message = 'Failed to Sign Up';
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading ? Center(child: CircularProgressIndicator()) : Container(
        height: MediaQuery.of(context).size.height,
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
                        TextFormField(                                          // username
                          validator: (val) {
                            if(val.isEmpty){
                              return "Please Enter username";
                            }
                            else if(val.contains('&')){
                              return "Username must not contain '&'";
                            }
                            else if(val.length <= 5){
                              return "username must be at least 5 characters";
                            }
                            return null;
                          },
                          controller: usernameTextEditingController,
                          style: mediumTextFieldStyle(),
                          decoration: textFieldInputDecoration('Username'),
                        ),
                        SizedBox(height: 10,),
                        TextFormField(                                          // email
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
                        TextFormField(                                          // password
                          validator: (val) {
                            if(val.isEmpty){
                              return "Please Enter password";
                            }
                            else if(val.length < 6){
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                          obscureText: true,
                          controller: passwordTextEditingController,
                          style: mediumTextFieldStyle(),
                          decoration: textFieldInputDecoration('Password'),
                        ),
                        message != null ? Container(                            // message
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
                  SizedBox(height: 28,),
                  GestureDetector(                                              // sign up button
                    onTap: () {
                      signMeUp();
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
                      child: Text("Sign Up", style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),),
                    ),
                  ),
                  SizedBox(height: 50,),
                  Row(                                                          // already have account
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have account?",
                        style: simpleTextFieldStyle(),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.toggle();
                        },
                        child: Text('Sign in', style: simpleTextFieldStyle(), ),

                      ),
                    ],
                  ),
                  // Spacer(flex: 1,)
                  // SizedBox(height: 40,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
