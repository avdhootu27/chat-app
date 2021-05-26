import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  uploadUserInfo(String userName, userMap) async {
    await FirebaseFirestore.instance.collection('users').doc(userName).set(userMap);
    await FirebaseFirestore.instance.collection('users').doc(userName).collection('contacts').doc('dummy').set({'dummy':'true'});
  }

  Future getUserByUsername(String username) async {
    return await FirebaseFirestore.instance.collection('users').where("name",isEqualTo: username).get();
  }

  Future getUserByUserEmail(String userEmail) async {
    return await FirebaseFirestore.instance.collection('users').where("email",isEqualTo: userEmail).get();
  }

  Future getUserPicByUsername(String username) async {
    return await FirebaseFirestore.instance.collection('users').doc(username).get();
  }

  createChatRoom(String chatRoomId, chatRoomMap) async {
    await FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId).set(chatRoomMap).catchError((e){
      print(e);
    });
  }

  updateChatRoom(String chatRoomId, time, String lastMessage) async {
    await FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId).update({'time' : time, 'lastMessage' : lastMessage}).catchError((e){
      print(e);
    });
  }

  checkChatRoom(String chatRoomId) async {
    return await FirebaseFirestore.instance.collection('chatRoom').where('chatRoomId', isEqualTo: chatRoomId).get();
  }

  addConversationMessages(String chatRoomId, messageMap, String Id) async {
    await FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId).collection('chats').doc(Id).set(messageMap).catchError((e){
      print(e);
    });
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId).collection('chats').orderBy('time', descending: true).snapshots();
  }

  deleteMessage(String chatRoomId, String id) async {
    await FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId).collection('chats').doc(id).delete().catchError((e){
      print(e);
    });
  }

  updateMessage(String chatRoomId, String time) async {
    await FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId).collection('chats').doc(time).update({'seen' : true}).catchError((e){
      print(e);
    });
  }
  
  getChatRooms(String userName) async {
    return await FirebaseFirestore.instance.collection('chatRoom').where('users',arrayContains: userName).where('time',isGreaterThan: 0).orderBy('time', descending: true).snapshots();
  }

  sendRequest(String me, String other, myInfoMap, otherInfoMap) async {
    await FirebaseFirestore.instance.collection('users').doc(me).collection('contacts').doc(other).set(myInfoMap);
    await FirebaseFirestore.instance.collection('users').doc(other).collection('contacts').doc(me).set(otherInfoMap);
  }

  acceptRequest(String me, String other) async {
    await FirebaseFirestore.instance.collection('users').doc(me).collection('contacts').doc(other).update({'request' : 'accepted'});
    await FirebaseFirestore.instance.collection('users').doc(other).collection('contacts').doc(me).update({'request' : 'accepted'});
  }

  deleteRequest(String me, String other) async {
    await FirebaseFirestore.instance.collection('users').doc(me).collection('contacts').doc(other).delete();
    await FirebaseFirestore.instance.collection('users').doc(other).collection('contacts').doc(me).delete();
  }

  deleteContact(String me, String other) async {
    await FirebaseFirestore.instance.collection('users').doc(me).collection('contacts').doc(other).delete();
    await FirebaseFirestore.instance.collection('users').doc(other).collection('contacts').doc(me).delete();
    String chatRoomId = getChatRoomId(me, other);
    await FirebaseFirestore.instance.collection('chatRoom').doc(chatRoomId).delete();
  }

  Future getContact(String userName, String userName2) async {
    return await FirebaseFirestore.instance.collection('users').doc(userName).collection('contacts').doc(userName2).get();
  }

  Future getSent(String userName) async {
    return await FirebaseFirestore.instance.collection('users').doc(userName).collection('contacts').where('request', isEqualTo: 'sent').snapshots();
  }
  
  Future getReceived(String userName) async {
    return await FirebaseFirestore.instance.collection('users').doc(userName).collection('contacts').where('request', isEqualTo: 'received').snapshots();
  }

  Future getContacts(String userName) async {
    return await FirebaseFirestore.instance.collection('users').doc(userName).collection('contacts').where('request', isEqualTo: 'accepted').snapshots();
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