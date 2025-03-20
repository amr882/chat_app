import 'package:chat_app/auth/services/auth_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future sadw() async {
    await AuthServices().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          onPressed: () {
            sadw();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil("signIn", (route) => false);
          },
          child: Text("signOut"),
        ),
      ),
    );
  }
}
