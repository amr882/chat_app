import 'package:chat_app/auth/services/chat_services.dart';
import 'package:chat_app/components/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ChatRoom extends StatefulWidget {
  final String receverEmail;
  final String receverId;
  final String receverName;
  final String receverPfp;
  const ChatRoom({
    super.key,
    required this.receverEmail,
    required this.receverId,
    required this.receverName,
    required this.receverPfp,
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
    return Container(
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.7, 02],
          colors: [Color(0xff121111), Color(0xff1c0d29)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              width: 100.w,
              height: 15.h,
              color: Color(0xff1f1f1f),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 10.h,
                      height: 10.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child:
                            widget.receverPfp.isNotEmpty
                                ? Image.network(
                                  widget.receverPfp,
                                  fit: BoxFit.cover,
                                  width: 8.h,
                                  height: 8.h,
                                )
                                : Image.asset(
                                  "assets/e8d7d05f392d9c2cf0285ce928fb9f4a.jpg",
                                ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    widget.receverName.replaceFirst(
                      widget.receverName[0],
                      widget.receverName[0].toUpperCase(),
                    ),
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 80.h, child: buildMessageList()),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.red,
                width: 100.w,
                height: 5.h,
                child: TextField(
                  controller: messageController,
                  onSubmitted: (value) {
                    sendMessage();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessageList() {
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
          children: [
            MessageBubble(
              message: data["message"],
              uSender: data["senderId"] == _firebaseAuth.currentUser!.uid,
            ),
            //Text(data["senderEmail"]), Text(data["message"])
          ],
        ),
      ),
    );
  }
}
