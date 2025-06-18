import 'package:chat_app/services/stories_services.dart';
import 'package:flutter/material.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  bool isLoading = false;
  String state = "no action";
  stories() async {
    setState(() {
      isLoading = true;
    });
    await StoriesServices().pickStory();
    setState(() {
      isLoading = false;
      state = "uploaded";
    });
    print(
      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++uploaded ",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading ? CircularProgressIndicator() : Text(state),
            MaterialButton(
              onPressed: () {
                stories();
              },
              color: Colors.red,
              child: Text("test"),
            ),
          ],
        ),
      ),
    );
  }
}
