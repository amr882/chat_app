import 'package:chat_app/components/stories_viewer.dart';
import 'package:chat_app/services/stories_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  Key _futureBuilderKey = UniqueKey();

  addStory() async {
    await StoriesServices().pickStory(context);
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
    print(
      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++uploaded ",
    );
  }

  @override
  Widget build(BuildContext context) {
    final storiesService = Provider.of<StoriesServices>(context);
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
                  storiesService.isLoading
                      ? Padding(
                        padding: EdgeInsets.all(2.h),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                      : Icon(Icons.add, color: Colors.white, size: 4.h),
            ),
            onPressed: () {
              if (!storiesService.isLoading) {
                addStory();
              }
            },
          ),
        ),
        backgroundColor: Colors.transparent,
        body:
            storiesService.isLoading
                ? Center(child: CircularProgressIndicator())
                : FutureBuilder(
                  key: _futureBuilderKey,
                  future: StoriesServices().getStories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          "No stories",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    print(snapshot.data);
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => StoriesViewer(
                                      usersStoriesIndex: snapshot.data!.length,
                                      allStories: snapshot.data,
                                    ),
                              ),
                            );
                          },

                          child: Text(
                            snapshot.data![index][0]["UserId"],
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }
}
