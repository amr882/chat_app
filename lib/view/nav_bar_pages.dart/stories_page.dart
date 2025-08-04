// ignore_for_file: avoid_types_as_parameter_names

import 'package:chat_app/components/stories/my_story_card.dart';
import 'package:chat_app/components/stories/stories_viewer.dart';
import 'package:chat_app/components/stories/user_story_card.dart';
import 'package:chat_app/services/stories_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  Key _friendStoriesFutureKey = UniqueKey();
  Key _myStoriesFutureKey = UniqueKey();

  addStory() async {
    await StoriesServices().pickStory(context);

    setState(() {
      _friendStoriesFutureKey = UniqueKey();
      _myStoriesFutureKey = UniqueKey();
    });
    print(
      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++uploaded ",
    );
  }

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String? pfp;
  getCurrentUserPfp() async {
    await firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((value) {
          var data = value.data() as Map<String, dynamic>;
          pfp = data["pfp"];
        });
  }

  @override
  void initState() {
    getCurrentUserPfp();
    super.initState();
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
                : Column(
                  children: [
                    // get my stories
                    FutureBuilder(
                      key: _myStoriesFutureKey,
                      future: StoriesServices().getCurrentUserStories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return MyStoryCard(userPhoto: pfp!);
                        }
                        int lastStory = snapshot.data!.last["uploading_date"];
                        return UserStoryCard(
                          totalStoriesLength: snapshot.data!.length,
                          userPhoto: pfp!,
                          userName: "my stories",
                          uploadDate: GetTimeAgo.parse(
                            DateTime.fromMicrosecondsSinceEpoch(lastStory),
                          ),
                          storyViewedCount: 0,
                        );
                      },
                    ),

                    // get friedns stories
                    FutureBuilder(
                      key: _friendStoriesFutureKey,
                      future: StoriesServices().getFirendsStories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }

                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              int lastStory =
                                  snapshot.data![index].last["uploading_date"];
                              int viewersCount = StoriesServices()
                                  .getStoryViewedCount(snapshot.data![index]);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => StoriesViewer(
                                            storyIndex: index,
                                            allStories: snapshot.data,
                                          ),
                                    ),
                                  );
                                },

                                child: UserStoryCard(
                                  totalStoriesLength:
                                      snapshot.data![index].length,
                                  userPhoto: snapshot.data![index][0]["pfp"],
                                  userName:
                                      snapshot.data![index][0]["userName"],
                                  uploadDate: GetTimeAgo.parse(
                                    DateTime.fromMicrosecondsSinceEpoch(
                                      lastStory,
                                    ),
                                  ),
                                  storyViewedCount: viewersCount,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
      ),
    );
  }
}
