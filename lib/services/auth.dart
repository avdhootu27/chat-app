
import 'package:chat_app/Module/user.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chat_row.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseMethods _databaseMethods = new DatabaseMethods();
  QuerySnapshot isUserNameAvailable;

  getCurrentUser() async {
    return await _auth.currentUser;
  }

  AppUser _userFromFirebaseUser(User user){
    return user != null ? AppUser(userId: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return 88.25;
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        return 88.26;
      }
    }
    catch(e){
      print(e.toString());
      return 88.27;
    }
  }

  Future userNameAvailable(String userName) async {
    bool answer;
    await _databaseMethods.getUserByUsername(userName).then((val){
      isUserNameAvailable = val;
      if(isUserNameAvailable != null){
        if(isUserNameAvailable.docs.length == 0){
          answer = true;
        }
        else{
          answer = false;
        }
      }
    });
    return answer;
  }

  Future signUpWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User firebaseuser = result.user;
      return _userFromFirebaseUser(firebaseuser);
    } on FirebaseException catch(e){
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        return 88.25;
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        return 88.26;
      }
    }
    catch (e) {
      print(e.toString());
      return 88.27;
    }
  }

  Future signInWithGoogle(BuildContext context) async {
    try{
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken
      );

      UserCredential result = await _firebaseAuth.signInWithCredential(credential);

      User userDetails = result.user;
      if(result != null){
        await HelperFunctions.saveUserEmailSharedPref(userDetails.email);
        await HelperFunctions.saveUserIDSharedPref(userDetails.uid);
        await HelperFunctions.saveUserProfilePicSharedPref(userDetails.photoURL);
        QuerySnapshot snap;
        var emailss = userDetails.email.split('@');
        String name = emailss[0];
        bool isFound = true;
        while(isFound){
          await _databaseMethods.getUserByUsername(name).then((val){
            snap = val;
            if(snap.size != 0){
              if(snap.docs[0].data()['email'] != userDetails.email){
                name = name + '_';
              }
              else{
                isFound = false;
              }
            }
            else{
              isFound = false;
            }
          });
        }
        await _databaseMethods.getUserByUserEmail(userDetails.email).then((val){
          snap = val;
          if(snap.size == 0){
            HelperFunctions.saveUserNameSharedPref(name);
          }
          else{
            HelperFunctions.saveUserNameSharedPref(snap.docs[0].data()['name']);
            name = snap.docs[0].data()['name'];
          }
        });
        Map<String, dynamic> userMap = {
          'email' : userDetails.email,
          'name' : name,
          'imgUrl' : userDetails.photoURL,
        };
        Constants.myName = name;
        Constants.myEmail = userDetails.email;
        await _databaseMethods.uploadUserInfo(name, userMap);
        await HelperFunctions.saveUserLoggedInSharedPref(true);
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => ChatRow(),
        ));

      }

    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return 88.25;
      }
    }
    catch(e){
      print(e);
      return 88.27;
    }
  }

  Future resetPassword(String email) async {
    try{
      return await _auth.sendPasswordResetEmail(email: email);
    }
    catch(e){
      print(e);
    }
  }

  Future signOut() async {
    try{
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.clear();
      return await _auth.signOut();
    }
    catch(e){
      print(e);
    }
  }

}