import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'file:///D:/Flutter_Projects/chat_app/lib/widgets/drawer.dart';
import 'package:chat_app/views/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRow extends StatefulWidget {
  @override
  _ChatRowState createState() => _ChatRowState();
}

class _ChatRowState extends State<ChatRow> {

  Stream chatRoomStream;

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  Widget ChatRoomList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshot) {
          return (snapshot.data != null && snapshot.data.docs.length != 0) ? ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                String name = getUserName(snapshot.data.docs[index].data()['chatRoomId'].toString());
                return ChatRoomTile(name, snapshot.data.docs[index].data()['chatRoomId'], snapshot.data.docs[index].data()['Time'],snapshot.data.docs[index].data()['lastMessage'], snapshot.data.docs[index].data()['${name}Pic']);
              }
          ) : Container(
            child: Center(
              child: Text('Search people to start conversation',style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 15,
              ),),
            ),
          );
        }
    );
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPref();
    Constants.myEmail = await HelperFunctions.getUserEmailSharedPref();
    Constants.myPic = await HelperFunctions.getUserProfilePicSharedPref();
    print(Constants.myName);
    databaseMethods.getChatRooms(Constants.myName).then((val){
      setState(() {
        chatRoomStream = val;
      });
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text('Flutter Chat App'),
        // actions: [
        //     Container(
        //       padding: EdgeInsets.symmetric(horizontal: 10),
        //         child: IconButton(
        //             icon: Icon(Icons.exit_to_app),
        //           tooltip: 'Sign Out',
        //           onPressed: () {
        //             authMethods.signOut().then((val){
        //               HelperFunctions.saveUserLoggedInSharedPref(false);
        //               Navigator.pushReplacement(context, MaterialPageRoute(
        //                 builder: (context) => Authenticate(),
        //               ));
        //             });
        //           },
        //         )
        //     ),
        // ],
      ),
      body: ChatRoomList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => Search(),
          ));
        },
        child: Icon(Icons.search),
        tooltip: 'Search people',
      ),
    );
  }
}

class ChatRoomTile extends StatefulWidget {

  final String userName;
  final String chatRoom;
  final String lastMessage;
  final String pic;
  final String Time;

  ChatRoomTile(this.userName,this.chatRoom, this.Time,this.lastMessage, this.pic);

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {

  bool pic = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => ConversationScreen(widget.chatRoom,widget.userName),
        ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            widget.pic != 'none' ? ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(imageUrl: widget.pic, width: 50, height: 50,fit: BoxFit.cover,),
            ) : Container(                                                          // icon
              alignment: Alignment.center,
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text('${widget.userName.substring(0,1).toUpperCase()}', style: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),),
            ),
            SizedBox(width: 8,),
            Container(
              width: MediaQuery.of(context).size.width - 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.userName,overflow: TextOverflow.ellipsis, style: TextStyle(                                    // username
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),),
                  Text(widget.lastMessage, overflow: TextOverflow.ellipsis,style: TextStyle(                                    // username
                    fontSize: 17,
                    color: Colors.white.withOpacity(0.7),
                  ),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String getUserName(String chatRoomId) {
  dynamic m = chatRoomId.split('&');
  if(m[0] == Constants.myName){
    return m[1];
  }
  else{
    return m[0];
  }
}
