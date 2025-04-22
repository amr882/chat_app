import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/auth/services/message_services.dart';
import 'package:chat_app/view/chat_room.dart';
import 'package:chat_app/widgets/friend_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

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
            // all users
            SizedBox(
              height: 17.h,
              child: Row(
                children: [SizedBox(width: 5.w), Expanded(child: _allUsers())],
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
                                        receverName: userData["Uemail"],
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
                      //stream to check if there is any messages
                      return StreamBuilder(
                        stream: MessageServices().hasMessages(userData["Uid"]),
                        builder: (context, snapshot) {
                          if (snapshot.data == true) {
                            // stream to get latest message
                            return StreamBuilder<String?>(
                              stream: MessageServices().lastMessageStream(
                                userData["Uid"],
                              ),
                              builder: (context, lastMessageSnapshot) {
                                // stream to get latest message time
                                return StreamBuilder<String?>(
                                  stream: MessageServices().lastMessageTime(
                                    userData["Uid"],
                                  ),
                                  builder: (context, lastMessageTime) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ChatRoom(
                                                  receverEmail:
                                                      userData["Uemail"],
                                                  receverId: userData["Uid"],
                                                  receverName:
                                                      userData["Uemail"],
                                                ),
                                          ),
                                        );
                                      },
                                      child: FriendChat(
                                        hasPhoto:
                                            userData["pfp"]
                                                .toString()
                                                .isNotEmpty,
                                        firendPhoto: userData["pfp"].toString(),

                                        friendName: userData["Uname"],
                                        lastMessage:
                                            lastMessageSnapshot.data ?? "",
                                        lastMessageTime:
                                            lastMessageTime.data ?? "",
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            return Container();
                          }
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
