import 'package:chat_app/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receverId, String message) async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final timestamp = Timestamp.now();
    Message messageInfo = Message(
      message: message,
      receverId: receverId,
      senderEmail: currentUserEmail,
      senderId: currentUserId,
      timestamp: timestamp,
    );

    List<String> usersId = [receverId, currentUserId];
    usersId.sort();
    String chatRoomId = usersId.join("_");
    await _firebaseFirestore
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("messages")
        .add(messageInfo.toJson());
  }

  Stream<QuerySnapshot> getMessage(String userId, String friendId) {
    List<String> ids = [userId, friendId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firebaseFirestore
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
