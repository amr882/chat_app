import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class StoriesViewer extends StatefulWidget {
  final int usersStoriesIndex;
  final List<List<Map<String, dynamic>>>? allStories;
  const StoriesViewer({
    super.key,
    required this.usersStoriesIndex,
    required this.allStories,
  });

  @override
  State<StoriesViewer> createState() => _StoriesViewerState();
}

class _StoriesViewerState extends State<StoriesViewer> {
  final controller = StoryController();
  @override
  void initState() {
    print(widget.usersStoriesIndex.toString());
    super.initState();
  }

  @override
  Widget build(context) {
    int index = widget.usersStoriesIndex;
    List<StoryItem> storyItems = [
      StoryItem.pageImage(
        caption: Text("111", style: TextStyle(color: Colors.white)),
        controller: controller,
        url:
            "https://i.pinimg.com/1200x/3a/8e/2d/3a8e2db0e5e3c48a6eb07f4f1868cf8d.jpg",
      ),
      StoryItem.pageImage(
        url:
            'https://i.pinimg.com/1200x/06/3f/c6/063fc6f586f932aa13549a702280a82f.jpg',
        controller: controller,
      ),
    ]; // your list of stories

    return Scaffold(
      body: PageView(
        children: [
          StoryView(
            controller: controller,
            repeat: false,
            onStoryShow: (storyItem, index) {
              print("viewed  ++++++++++++++++--------");
            },
            onComplete: () {
              if (index < 1) {
                print("there is more");
                index--;
              } else {
                print("thats all done");
                Navigator.of(context).pop();
              }
            },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Navigator.pop(context);
              }
            },
            storyItems: storyItems,
          ),
        ],
      ),
    );
  }
}
