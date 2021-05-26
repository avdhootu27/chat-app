import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

ScrollController _scrollController = ScrollController();

class ConversationScreen extends StatefulWidget {

  final String chatRoomId;
  final String userName;
  String pic = 'none';
  ConversationScreen(this.chatRoomId,this.userName);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  Stream chatMessageStream;

  TextEditingController messageTextEditingController = new TextEditingController();

  DatabaseMethods databaseMethods = new DatabaseMethods();

  Widget ChatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
        builder: (context, snapshot){
          return snapshot.data != null ? ListView.builder(
              controller: _scrollController,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                reverse: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index){
                String id = '${snapshot.data.docs[index].data()['Time']}+${snapshot.data.docs[index].data()['time']}';
                  return Dismissible(
                      key: Key(id),
                      onDismissed: (direction) {
                        databaseMethods.deleteMessage(widget.chatRoomId, id);
                      },
                      child: MessageTile(snapshot.data.docs[index].data()['message'], snapshot.data.docs[index].data()['Time'],snapshot.data.docs[index].data()['time'],snapshot.data.docs[index].data()['seen'],snapshot.data.docs[index].data()['sendBy'] == Constants.myName, snapshot.data.docs.length - 1 - index, widget.chatRoomId, widget.userName),
                      );
              }
          ) : Container();
        }
    );
  }

  sendMessage() async {
    if(messageTextEditingController.text.isNotEmpty){
      dynamic time =  DateTime.now().microsecondsSinceEpoch;
      var now = new DateTime.now();
      var formatter = new DateFormat('dd MMMM yy');
      String formattedTime = DateFormat('h:mm a').format(now);
      String formattedDate = formatter.format(now);
      String Time = '$formattedDate, $formattedTime';
      Map<String, dynamic> messageMap = {
        'message' : messageTextEditingController.text,
        'sendBy' : Constants.myName,
        'time' : time,
        'Time' : Time,
        'seen' : false,
      };
      await databaseMethods.addConversationMessages(widget.chatRoomId, messageMap, '$Time+$time');
      await databaseMethods.updateChatRoom(widget.chatRoomId, time, messageTextEditingController.text);
      setState(() {
        messageTextEditingController.text = '';
      });
    }
  }

  getPicUrl(String userName) async {
    QuerySnapshot user;
    DatabaseMethods databaseMethods = new DatabaseMethods();
    databaseMethods.getUserByUsername(userName).then((val){
      user = val;
      widget.pic = user.docs[0].data()['imgUrl'];
      setState(() {});
    });
  }

  @override
  void initState() {
    getPicUrl(widget.userName);
    databaseMethods.getConversationMessages(widget.chatRoomId).then((val){
      setState(() {
        chatMessageStream = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Container(
              width: MediaQuery.of(context).size.width*0.7,
              child: Text(widget.userName,overflow: TextOverflow.ellipsis,),
          ),
          leadingWidth: 80,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Row(
              children: [
                SizedBox(width: 5,),
                Icon(Icons.arrow_back, size: 25,),
                SizedBox(width: 5,),
                widget.pic != 'none' ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(imageUrl: widget.pic, width: 40, height: 40,fit: BoxFit.cover,),
                ) :Container(                                                          // icon
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text('${widget.userName.substring(0,1).toUpperCase()}', style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),),
                ),
            ],
        ),
          ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // Container(
                Expanded(
                    child: Container(
                        alignment: Alignment.bottomCenter,
                        child: ChatMessageList()
                    ),
                ),
              // ),
              Container(                                                        // message type bar
                color: Color(0xff1F1F1F),
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 50,
                  margin: EdgeInsets.only(left: 5,right: 5,bottom: 5),
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                  decoration: BoxDecoration(
                    color: Color(0x54FFFFFF),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextField(
                            controller: messageTextEditingController,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Message ...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              border: InputBorder.none,
                            ),
                          )
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
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
                              child: Center(child: Image.asset('assets/send.png')),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}


class MessageTile extends StatefulWidget {
  final String message;
  final bool isSendByMe;
  final int index;
  final String chatroomId;
  final String userName;
  final String Time;
  final int time;
  final bool seen;
  MessageTile(this.message,this.Time,this.time,this.seen,this.isSendByMe,this.index,this.chatroomId,this.userName);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool done = false;
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key('${widget.Time}+${widget.time.toString()}'),
        onVisibilityChanged: (visibilityInfo) {
          // print('seen ${widget.message}');
          // print(!widget.isSendByMe);
          // print(widget.seen);
          if(!widget.isSendByMe && widget.seen == false){
            // print('inside');
            // print('${widget.Time}+${widget.time.toString()}');
            databaseMethods.updateMessage(widget.chatroomId, '${widget.Time}+${widget.time.toString()}');
          }
    },
    child: Container(
      width: MediaQuery.of(context).size.width,
      alignment: widget.isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: widget.isSendByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                done = !done;
              });
            },
            child: Container(
              constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width)*0.8),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isSendByMe ? [
                    const Color(0xff807eF4),
                    const Color(0xff2A75BC),
                  ] : [
                    const Color(0x1AFFFFFF),
                    const Color(0x1AFFFFFF),
                  ],
                ),
                borderRadius: widget.isSendByMe ? BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: widget.seen ? Radius.circular(2) : Radius.circular(20),
                ) : BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(2),
                )
              ),
              child:Text(widget.message,style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),),
              ),
            ),
          done ? Container(
            padding: widget.isSendByMe ? EdgeInsets.only(right: 10,bottom: 5) : EdgeInsets.only(left: 10,bottom: 5),
            child: Text(widget.Time, style: TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),),
          ) :  Container(),
        ],
      ),
      ),
    );
  }
}
