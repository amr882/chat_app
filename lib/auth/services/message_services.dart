import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageServices {
  final _auth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  Stream<String?> lastMessageStream(String receiverId) {
    try {
      List<String> ids = [_auth.currentUser!.uid, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      return _firebaseFirestore
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("messageTime", descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              return snapshot.docs.first["senderId"] == _auth.currentUser!.uid
                  ? "✓✓  ${snapshot.docs.first["message"]}"
                  : "${snapshot.docs.first["message"]}";
            }
            return null;
          });
    } catch (e) {
      print("Error getting latest message stream: $e");
      return Stream.value(null);
    }
  }

  Stream<String?> lastMessageTime(String receiverId) {
    try {
      List<String> ids = [_auth.currentUser!.uid, receiverId];
      ids.sort();
      String chatRoomId = ids.join("_");

      return _firebaseFirestore
          .collection("chatRoom")
          .doc(chatRoomId)
          .collection("messages")
          .orderBy("messageTime", descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              DateTime datatime = DateTime.fromMicrosecondsSinceEpoch(
                snapshot.docs.first["messageTime"],
              );

              return timeago.format(datatime).toString();
            }
            return null;
          });
    } catch (e) {
      print("Error getting latest message stream: $e");
      return Stream.value(null);
    }
  }

  Stream hasMessages(String receiverId) {
    List<String> ids = [_auth.currentUser!.uid, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firebaseFirestore
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("messages")
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }
}
