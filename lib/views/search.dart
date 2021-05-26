import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String other, me;

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  bool userFound = true;
  QuerySnapshot searchSnapshot;
  TextEditingController searchTextEditingController = new TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();

  initiateSearch() {
    databaseMethods.getUserByUsername(searchTextEditingController.text).then((val){
      setState(() {
        searchSnapshot = val;
        if(searchSnapshot.docs.length == 0){
          userFound = false;
        }
        else{
          userFound = true;
        }
      });
    });
  }

  Widget searchList(){
    return searchSnapshot != null ? ListView.builder(
        itemCount: searchSnapshot.docs.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
          return SearchTile(
            username: searchSnapshot.docs[index].data()['name'],
            useremail: searchSnapshot.docs[index].data()['email'],
            pic: searchSnapshot.docs[index].data()['imgUrl'],
          );
        }
    ) : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
              decoration: BoxDecoration(
                color: Color(0x54FFFFFF),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(                                                       // search bar row
                children: [
                  Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'search username',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                          border: InputBorder.none,
                        ),
                      )
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        searchSnapshot = null;
                      });
                      initiateSearch();
                    },
                    child: Container(
                        height: 35,
                          width: 35,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0x36FFFFFF),
                                const Color(0x0FFFFFFF),
                              ]
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          // child: FloatingActionButton(
                          //   backgroundColor: Colors.transparent,
                          //   foregroundColor: Colors.transparent,
                          //   onPressed: () {
                          //     setState(() {
                          //       initiateSearch();
                          //     });
                          //
                          //   },
                          //   tooltip: 'search',
                          //     child: Image.asset('assets/search_white.png'),
                          // ),
                          child: Center(child: Image.asset('assets/search_white.png'),),
                      ),
                  ),
                ],
              ),
            ),
            userFound ? searchList() : Expanded(                                 // no user found
                child: Column(
                  children: [
                    Spacer(),
                    Text('No User Found',style: TextStyle(
                      color: Colors.yellow,
                    ),),
                    Spacer(flex: 2,),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTile extends StatefulWidget {
  final String username;
  final String useremail;
  final String pic;
  String chatSt;
  SearchTile({this.username, this.useremail, this.pic});

  @override
  _SearchTileState createState() => _SearchTileState();
}

class _SearchTileState extends State<SearchTile> {

  DatabaseMethods databaseMethods = new DatabaseMethods();


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
      List<dynamic> users = [userName,Constants.myName];
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

  getChatStatus(String userName) async {
    DatabaseMethods databaseMethods = new DatabaseMethods();
    DocumentSnapshot snap;
    await databaseMethods.getContact(Constants.myName, userName).then((snap){
      if(snap.exists){
        if(snap.data()['request'] == 'sent'){
          setState(() {
            widget.chatSt = 'Pending';
          });
        }
        else if(snap.data()['request'] == 'received'){
          setState(() {
            widget.chatSt = 'Accept';
          });
        }
        else if(snap.data()['request'] == 'accepted'){
          setState(() {
            widget.chatSt = 'Message';
          });
        }
      }
      else{
        setState(() {
          widget.chatSt = 'Request';
        });
      }
    });
  }

  @override
  void initState() {
    getChatStatus(widget.username);
    setState(() {

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
      child: Row(
        children: [
          widget.pic != 'none' ? ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(imageUrl: widget.pic, width: 50, height: 50,fit: BoxFit.cover,),
          ) :Container(                                                          // icon
            alignment: Alignment.center,
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text('${widget.username.substring(0,1).toUpperCase()}', style: TextStyle(
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
                Text(widget.username,style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )),
                Text(widget.useremail,overflow: TextOverflow.ellipsis,style:  TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ))
              ],
            ),
          ),
          Spacer(),
          (widget.username != Constants.myName) ? GestureDetector(
            onTap: () {
              if(widget.chatSt == 'Message'){
                createChatRoomAndStartConversation(userName: widget.username);
              }
              else if(widget.chatSt == 'Pending'){

              }
              else if(widget.chatSt == 'Request'){
                Map<String, dynamic> myInfoMap = {'name':widget.username, 'imgUrl':widget.pic, 'request':'sent'};
                Map<String, dynamic> otherInfoMap = {'name':Constants.myName, 'imgUrl':Constants.myPic, 'request':'received'};
                databaseMethods.sendRequest(Constants.myName, widget.username, myInfoMap, otherInfoMap);
                setState(() {
                  widget.chatSt = 'Pending';
                });
              }
              else if(widget.chatSt == 'Accept'){
                databaseMethods.acceptRequest(Constants.myName, widget.username);
                setState(() {
                    widget.chatSt = 'Message';
                });
              }
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
              child: widget.chatSt != null ? Text(widget.chatSt, style: TextStyle(
                color: Colors.white,
              ),) : Container(),
            ),
          ) : Container(),
        ],
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

