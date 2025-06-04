// ignore_for_file: deprecated_member_use

import 'package:chat_app/auth/services/chat_services.dart';
import 'package:chat_app/components/message_bubble.dart';
import 'package:chat_app/components/message_field.dart';
import 'package:chat_app/components/message_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  // pick image

  // sendPhoto() async {
  //   ChatServices().sendPhoto(widget.receverId);
  // }

  sendPhoto() async {
    var photo = await ChatServices().pickImage();
    await ChatServices().sendMessage(widget.receverId, photo.toString());
  }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      ChatServices().sendMessage(widget.receverId, messageController.text);
    }
    messageController.clear();
  }

  final ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Future.delayed(Duration(seconds: 3), () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollDown();
          });
        });
      }
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollDown();
    });
  }

  scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    focusNode.dispose();
    scrollController.dispose();

    super.dispose();
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
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SafeArea(
              child: Container(
                width: 100.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: Color(0xff1f1f1f),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),

                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 7.h,
                        height: 7.h,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child:
                              widget.receverPfp.isNotEmpty
                                  ? Image.network(
                                    widget.receverPfp,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    "assets/e8d7d05f392d9c2cf0285ce928fb9f4a.jpg",
                                    fit: BoxFit.cover,
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
            ),

            Expanded(child: buildMessageList()),

            // text field to send messages
            Container(
              decoration: BoxDecoration(
                color: Color(0xff1f1f1f),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),

              width: 100.w,
              height: 10.h,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      // send file
                      child: GestureDetector(
                        onTap: () {
                          sendPhoto();
                        },
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              "assets/attachment-2-svgrepo-com.svg",
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: MessageField(
                        controller: messageController,
                        focusNode: focusNode,
                      ),
                    ),
                    GestureDetector(
                      // send message
                      onTap: () => sendMessage(),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SvgPicture.asset("assets/Send.svg"),
                        ),
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollDown();
        });
        return MessageList(
          scrollController: scrollController,
          scrollDown: () {
            scrollDown();
          },
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
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
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
          ],
        ),
      ),
    );
  }
}
