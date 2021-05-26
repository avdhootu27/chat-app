import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


String me, other;

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  Stream contactStream;

  DatabaseMethods databaseMethods = new DatabaseMethods();

  initiateSearch() async {
    await databaseMethods.getContacts(Constants.myName).then((val){
      setState(() {
        contactStream = val;
      });
    });
  }

  createChatRoomAndStartConversation({String userName}) async {
    String chatRoomId = getChatRoomId(userName, Constants.myName);
    QuerySnapshot snap;
    bool here = false;
    await databaseMethods.checkChatRoom(chatRoomId).then((val){
      snap = val;
      if(snap.size == 0){
        here = true;
      }
    });
    if(here){
      await getPicUrl1(userName);
      await getPicUrl2(Constants.myName);
      var  users = <String> [userName,Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        "users" : users,
        "chatRoomId" : chatRoomId,
        'time' : 0,
        'lastMessage' : '',
        '${users[0]}Pic' : other,
        '${users[1]}Pic' : me,
      };
      await DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
    }
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => ConversationScreen(chatRoomId,userName),
    ));
  }

  Widget personTile(String name, String pic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
      child: Row(
        children: [
          pic != 'none' ? ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(imageUrl: pic, width: 50, height: 50,fit: BoxFit.cover,),
          ) :Container(                                                          // icon
            alignment: Alignment.center,
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text('${name.substring(0,1).toUpperCase()}', style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),),
          ),
          SizedBox(width: 10,),
          Container(
            width: MediaQuery.of(context).size.width*0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )),
                // Text(widget.useremail,overflow: TextOverflow.ellipsis,style:  TextStyle(
                //   fontSize: 14,
                //   color: Colors.white.withOpacity(0.7),
                // ))
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoomAndStartConversation(userName: name);
            },
            child: Container(
              width: MediaQuery.of(context).size.width*0.2,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              alignment: Alignment.center,
              child: Text('Message', style: TextStyle(
                color: Colors.white,
              ),),
              ),
            ),
        ],
      ),
    );
  }

  Widget List() {
    return StreamBuilder(
        stream: contactStream,
        builder: (context, snapshot) {
          return (snapshot.data != null && snapshot.data.docs.length != 0) ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String name = snapshot.data.docs[index].data()['name'];
                return Dismissible(
                  key: Key(name),
                  onDismissed: (direction) {
                    databaseMethods.deleteContact(Constants.myName, snapshot.data.docs[index].data()['name']);
                  },
                  child: personTile(name, snapshot.data.docs[index].data()['imgUrl']),
                  background: Container(color: Colors.red),
                );
              }
          ) : Container(
            child: Center(
              child: Text('No contacts',style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
              ),),
            ),
          );
        }
    );
  }

  @override
  void initState() {
    initiateSearch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Container(
        child: List(),
      ),
    );
  }
}


getChatRoomId(String a, String b){
  if(a.compareTo(b) == 1){
    return "$b\&$a";
  }
  else{
    return "$a\&$b";
  }
}

getPicUrl1(String userName) async {
  QuerySnapshot user;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  await databaseMethods.getUserByUsername(userName).then((val){
    user = val;
    other = user.docs[0].data()['imgUrl'];
  });
}

getPicUrl2(String userName) async {
  QuerySnapshot user;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  await databaseMethods.getUserByUsername(userName).then((val){
    user = val;
    me = user.docs[0].data()['imgUrl'];
  });
}

