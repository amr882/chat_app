import 'package:chat_app/auth/services/auth_services.dart';
import 'package:chat_app/view/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signOut() async {
    AuthServices().signOut();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: signOut, icon: Icon(Icons.exit_to_app)),
        ],
      ),
      body: _usersList(),
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
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => ChatRoom(
                    receverEmail: data["Uemail"],
                    receverId: data["Uid"],
                  ),
            ),
          );
        },
        child: ListTile(title: Text(data["Uemail"])),
      );
    } else {
      return Container();
    }
  }
}
