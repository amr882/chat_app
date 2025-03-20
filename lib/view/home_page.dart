import 'package:chat_app/auth/services/auth_services.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _usersList());
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
      return ListTile(title: Text(data["Uemail"]));
    } else {
      return Container();
    }
  }
}







//   Future signOut()async{
//        AuthServices().signOut();
//   }
//   @override
//   void initState() {
// signOut();
// Navigator.of(context).pop();
//     super.initState();
//   }