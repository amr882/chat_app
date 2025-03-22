import 'package:chat_app/auth/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String receverEmail;
  final String receverId;
  final String receverName;
  const ChatRoom({
    super.key,
    required this.receverEmail,
    required this.receverId,
    required this.receverName,
  });

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController messageController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  ChatServices chatServices = ChatServices();
  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      ChatServices().sendMessage(widget.receverId, messageController.text);
    }
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),

          Row(
            children: [
              Expanded(child: TextField(controller: messageController)),
              IconButton(
                onPressed: () {
                  sendMessage();
                },
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: chatServices.getMessage(
        _firebaseAuth.currentUser!.uid,
        widget.receverId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("error getting messages"));
        }
        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessage(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessage(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    Alignment alignment =
        (data["senderId"] == _firebaseAuth.currentUser!.uid
            ? Alignment.centerRight
            : Alignment.centerLeft);
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              data["senderId"] == _firebaseAuth.currentUser!.uid
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [Text(data["senderEmail"]), Text(data["message"])],
        ),
      ),
    );
  }
}
