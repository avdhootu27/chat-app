import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/authenticate.dart';
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperFunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/contacts.dart';
import 'package:chat_app/views/request.dart';
import 'package:chat_app/views/settings.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width*0.70,
        color: Color(0xFFCACBCB),
        child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height*0.27,
            width: MediaQuery.of(context).size.width*0.70,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff145C9E),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft: Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Container(
                    child: Constants.myPic != 'none' ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(imageUrl: Constants.myPic, width: 80, height: 80,fit: BoxFit.cover,),
                    ) : Container(                                                          // icon
                          alignment: Alignment.center,
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                      child: Text('${Constants.myName.substring(0,1).toUpperCase()}', style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                      ),),
                    ),
                  ),
                  SizedBox(height: 15,),
                  AutoSizeText('${Constants.myName}', overflow: TextOverflow.ellipsis, maxLines: 1,minFontSize: 20,maxFontSize: 25 ,style: TextStyle(color: Colors.white),),
                  SizedBox(height: 7,),
                  AutoSizeText('${Constants.myEmail}',overflow: TextOverflow.ellipsis, maxLines: 1,minFontSize: 12,maxFontSize: 25 ,style: TextStyle(color: Colors.white.withOpacity(0.7)),),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.assignment_ind_outlined),
            minLeadingWidth: 5,
            title: Text('Chat Requests',style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Requests(),
              ));
            },
          ),
          Divider(color: Color(0xFF6B6D6F), indent: 10,endIndent: 10,),
          ListTile(
            leading: Icon(Icons.contacts),
            minLeadingWidth: 5,
            title: Text('Contacts',style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Contacts(),
              ));
            },
          ),
          // Divider(color: Color(0xFF6B6D6F), indent: 10,endIndent: 10,),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   minLeadingWidth: 5,
          //   title: Text('Settings',style: TextStyle(
          //     fontSize: 15,
          //     fontWeight: FontWeight.w500,
          //   ),),
          //   onTap: () {
          //     Navigator.push(context, MaterialPageRoute(
          //       builder: (context) => Settings(),
          //     ));
          //   },
          // ),
          Divider(color: Color(0xFF6B6D6F), indent: 10,endIndent: 10,),
          ListTile(
            leading: Icon(Icons.logout),
            minLeadingWidth: 5,
            title: Text('Sign Out',style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),),
            onTap: () {
              authMethods.signOut().then((val){
                HelperFunctions.saveUserLoggedInSharedPref(false);
                Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => Authenticate(),
                ));
              });
              // Navigator.pop(context);
            },
          ),
        ],
      ),
      ),
    );
  }
}
