import 'dart:io';

import 'package:chat_app/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receverId, String message) async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final timestamp = Timestamp.now().microsecondsSinceEpoch;
    Message messageInfo = Message(
      message: message,
      receverId: receverId,
      senderEmail: currentUserEmail,
      senderId: currentUserId,
      messageTime: timestamp,
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

  File? imageFile;

  pickImage() async {
    ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    imageFile = File(image.path);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    await uploadImage(fileName);
    return Supabase.instance.client.storage
        .from('chatpfp')
        .getPublicUrl('uploads/$fileName');
  }

  Future<void> uploadImage(String fileName) async {
    if (imageFile == null) return;

    final path = "uploads/$fileName";
    try {
      await Supabase.instance.client.storage
          .from("chatpfp")
          .upload(path, imageFile!);
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Stream<QuerySnapshot> getMessage(String userId, String friendId) {
    List<String> ids = [userId, friendId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firebaseFirestore
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('messageTime', descending: false)
        .snapshots();
  }
}
