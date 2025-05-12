import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/auth/services/message_services.dart';
import 'package:chat_app/view/chat_room.dart';
import 'package:chat_app/widgets/friend_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future signOut() async {
    AuthServices().signOut();

    Navigator.of(context).pushNamedAndRemoveUntil("signIn", (route) => false);
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Messages",
            style: GoogleFonts.rubik(
              color: Colors.white,
              fontSize: 3.6.h,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            IconButton(onPressed: signOut, icon: Icon(Icons.exit_to_app)),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: Color(0xff1f1f1f),
                  borderRadius: BorderRadius.circular(30),
                ),
                width: 100.w,
                height: 7.h,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Search..",
                        style: GoogleFonts.rubik(
                          color: Color(0xff4d4c4e),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SvgPicture.asset("assets/Search.svg"),
                    ],
                  ),
                ),
              ),
            ),

            // all users
            SizedBox(
              height: 20.h,
              child: Row(
                children: [SizedBox(width: 5.w), Expanded(child: _allUsers())],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 7.w),
                  Container(
                    width: 20.w,
                    height: 5.h,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.7, 02],
                        colors: [Color(0xff6a2cf8), Color(0xffa763fe)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Recents",
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _chatList()),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _usersStream() {
    return _firebaseFirestore.collection("users").snapshots();
  }

  Widget _allUsers() {
    return StreamBuilder(
      stream: _usersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error getting users list: ${snapshot.error}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found."));
        }
        return SizedBox(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                snapshot.data!.docs.map<Widget>((document) {
                  Map<String, dynamic> userData =
                      document.data() as Map<String, dynamic>;

                  if (userData["Uemail"] != _auth.currentUser!.email) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 2.h,
                        horizontal: 2.w,
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatRoom(
                                        receverEmail: userData["Uemail"],
                                        receverId: userData["Uid"],
                                        receverName: userData["Uname"],
                                        receverPfp: userData["pfp"],
                                      ),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 10.h,
                              height: 10.h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child:
                                    userData["pfp"].toString().isNotEmpty
                                        ? Image.network(
                                          userData["pfp"].toString(),
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
                          Text(
                            userData["Uname"],
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                }).toList(),
          ),
        );
      },
    );
  }

  Widget _chatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error getting users list: ${snapshot.error}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        return ListView(
          children:
              snapshot.data!.docs
                  .map<Widget>((document) {
                    Map<String, dynamic> userData =
                        document.data() as Map<String, dynamic>;

                    if (userData["Uemail"] != _auth.currentUser!.email) {
                      return StreamBuilder(
                        stream: MessageServices().message(userData["Uid"]),
                        builder: (context, messageSnapshot) {
                          if (messageSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: Container());
                          } else if (messageSnapshot.hasError) {
                            return Center(
                              child: Text(
                                "Error getting users list: ${messageSnapshot.error}",
                              ),
                            );
                          } else if (!messageSnapshot.hasData) {
                            return Container();
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatRoom(
                                        receverEmail: userData["Uemail"],
                                        receverId: userData["Uid"],
                                        receverName: userData["Uname"],
                                        receverPfp: userData["pfp"],
                                      ),
                                ),
                              );
                            },
                            child: FriendChat(
                              hasPhoto: userData["pfp"].toString().isNotEmpty,
                              firendPhoto: userData["pfp"].toString(),

                              friendName: userData["Uname"],
                              lastMessage:
                                  messageSnapshot.data[0]["senderId"] ==
                                          _auth.currentUser!.uid
                                      ? "✓✓ ${messageSnapshot.data[0]["message"]}"
                                      : messageSnapshot.data[0]["message"],
                              lastMessageTime:
                                  timeago
                                      .format(
                                        DateTime.fromMicrosecondsSinceEpoch(
                                          messageSnapshot
                                              .data[0]["messageTime"],
                                        ),
                                      )
                                      .toString(),
                            ),
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  })
                  .toList()
                  .reversed
                  .toList(),
        );
      },
    );
  }
}
