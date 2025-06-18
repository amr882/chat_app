import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatServices {
  final _auth = FirebaseAuth.instance;
  final _firebaseFirestore = FirebaseFirestore.instance;

  Stream message(String receiverId) {
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
              return snapshot.docs;
            }
            return null;
          });
    } catch (e) {
      print("Error getting latest message stream: $e");
      return Stream.value(null);
    }
  }
}
