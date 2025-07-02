import 'package:chat_app/services/stories_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  bool isLoading = false;

  stories() async {
    setState(() {
      isLoading = true;
    });
    await StoriesServices().pickStory(context);
    setState(() {
      isLoading = false;
    });
    print(
      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++uploaded ",
    );
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Stories",
            style: GoogleFonts.rubik(
              color: Colors.white,
              fontSize: 3.6.h,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: FloatingActionButton(
            shape: CircleBorder(),
            backgroundColor: Color(0xff7c01f6),
            child: Center(
              child:
                  isLoading
                      ? Padding(
                        padding: EdgeInsets.all(2.h),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : Icon(Icons.add, color: Colors.white, size: 4.h),
            ),
            onPressed: () {
              stories();
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        body: FutureBuilder(
          future: StoriesServices().getStrories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("error getting stories"));
            }
            print(snapshot.data);
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Text(
                  snapshot.data![index]["story_id"],
                  style: TextStyle(color: Colors.white),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
