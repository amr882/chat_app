import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/view/chat_room.dart';
import 'package:chat_app/widgets/friend_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
            // all users
            SizedBox(
              height: 14.h,
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
                      child: GestureDetector(
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

  Stream<String?> _lastMessageStream(String receiverId) {
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
              snapshot.data!.docs.map<Widget>((document) {
                Map<String, dynamic> userData =
                    document.data() as Map<String, dynamic>;

                if (userData["Uemail"] != _auth.currentUser!.email) {
                  return StreamBuilder(
                    stream: hasMessages(userData["Uid"]),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return StreamBuilder<String?>(
                          stream: _lastMessageStream(userData["Uid"]),
                          builder: (context, lastMessageSnapshot) {
                            return StreamBuilder<String?>(
                              stream: lastMessageTime(userData["Uid"]),
                              builder: (context, lastMessageTime) {
                                return GestureDetector(
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
                                  child: FriendChat(
                                    hasPhoto:
                                        userData["pfp"].toString().isNotEmpty,
                                    firendPhoto: userData["pfp"].toString(),

                                    friendName: userData["Uname"],
                                    lastMessage: lastMessageSnapshot.data ?? "",
                                    lastMessageTime: lastMessageTime.data!,
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
              }).toList(),
        );
      },
    );
  }
}
