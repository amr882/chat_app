import 'package:chat_app/auth/services/auth_services.dart';
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

  Future signOut() async {
    AuthServices().signOut();

    Navigator.of(context).pushNamedAndRemoveUntil("signIn", (route) => false);
  }

  // 1c0d29
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
          // actions: [
          //   IconButton(onPressed: signOut, icon: Icon(Icons.exit_to_app)),
          // ],
        ),
        body: Column(
          children: [Row(children: []), Expanded(child: _usersList())],
        ),
      ),
    );
  }

  Widget _usersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("users").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.none) {
          return Center(child: Text("error getting users List"));
        }

        return ListView(
          children:
              snapshot.data!.docs
                  .map<Widget>((e) => _usersListBuilder(e))
                  .toList(),
        );
      },
    );
  }

  Widget _usersListBuilder(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    if (data["Uemail"] != _auth.currentUser!.email) {
      return FriendChat(
        firendPhoto:
            "https://i.pinimg.com/736x/25/62/be/2562beb757b9ef9735ee01a1de370f04.jpg",
        friendName: data["Uname"],
        lastMessage: 'last message',
      );

      //  GestureDetector(
      //   onTap: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder:
      //             (context) => ChatRoom(
      //               receverEmail: data["Uemail"],
      //               receverId: data["Uid"],
      //               receverName: data["Uemail"],
      //             ),
      //       ),
      //     );
      //   },
      //   child: ListTile(title: Text(data["Uname"] ?? data["Uemail"])),
      // );
    } else {
      return Container();
    }
  }
}
