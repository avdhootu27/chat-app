import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';

class Requests extends StatefulWidget {
  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {

  Stream sentStream;
  Stream receivedStream;

  DatabaseMethods databaseMethods = new DatabaseMethods();

  initiateSearch() async {
    await databaseMethods.getSent(Constants.myName).then((val){
      setState(() {
        sentStream = val;
      });
    });
    await databaseMethods.getReceived(Constants.myName).then((val){
      setState(() {
        receivedStream = val;
      });
    });
  }

  Widget personTile(String name, String pic, String type) {
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
              if(type == 'received'){
                databaseMethods.acceptRequest(Constants.myName, name);
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
              child: type == 'sent' ? Text('Pending', style: TextStyle(
                color: Colors.white,
              ),) : Text('Accept', style: TextStyle(
                      color: Colors.white,
                    ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget List(String type) {
    return StreamBuilder(
      stream: type == 'sent' ? sentStream : receivedStream,
      builder: (context, snapshot) {
        return (snapshot.data != null && snapshot.data.docs.length != 0) ? ListView.builder(
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              String name = snapshot.data.docs[index].data()['name'];
              return Dismissible(
                  key: Key(name),
                  onDismissed: (direction) {
                    databaseMethods.deleteRequest(Constants.myName, snapshot.data.docs[index].data()['name']);
                  },
                  child: personTile(snapshot.data.docs[index].data()['name'], snapshot.data.docs[index].data()['imgUrl'], type),
                  background: Container(color: Colors.red),
              );
            }
        ) : Container(
          child: Center(
            child: Text('No requests found',style: TextStyle(
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text('SENT'),
                ),
              ),
              Tab(
                child: Align(
                  alignment: Alignment.center,
                  child: Text('RECEIVED'),
                ),
              ),
            ],
          ),
          title: Text('Requests'),
        ),
        body: TabBarView(
          children: [
            Container(
              child: List('sent'),
            ),
            Container(
              child: List('received'),
            ),
          ],
        ),
      ),
    );
  }
}

