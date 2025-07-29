import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class StoriesViewer extends StatefulWidget {
  final int storyIndex;
  final List<List<Map<String, dynamic>>>? allStories;

  const StoriesViewer({
    super.key,
    required this.storyIndex,
    required this.allStories,
  });

  @override
  State<StoriesViewer> createState() => _StoriesViewerState();
}

class _StoriesViewerState extends State<StoriesViewer> {
  final controller = StoryController();
  List<List<Map<String, dynamic>>> _displayStories = [];
  // get all stories after the selected story index
  // storiesAfterIndex() {
  //   int indexToRemoveBefore = widget.storyIndex;
  //   if (indexToRemoveBefore > 0 &&
  //       indexToRemoveBefore <= _displayStories!.length) {
  //     _displayStories!.removeRange(0, indexToRemoveBefore);
  //     print(_displayStories);
  //   } else if (indexToRemoveBefore == 0) {
  //     print("first");
  //   } else {}
  // }

  markAsViewedByCurrentUser() async {}

  @override
  void initState() {
    super.initState();

    if (widget.allStories!.isNotEmpty) {
      _displayStories = List.from(widget.allStories!);
      if (widget.storyIndex > 0 && widget.storyIndex < _displayStories.length) {
        _displayStories.removeRange(0, widget.storyIndex);
      } else if (widget.storyIndex >= _displayStories.length) {
        _displayStories = [];
      }
    }
  }

  final PageController _pageController = PageController();
  @override
  Widget build(context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: List.generate(_displayStories.length, (userIndex) {
          List<StoryItem>
          storyItems = List.generate(_displayStories[userIndex].length, (
            storyIndex,
          ) {
            return _displayStories[userIndex][storyIndex]["story_type"] ==
                    "video"
                ? StoryItem.pageVideo(
                  duration: Duration(
                    milliseconds:
                        _displayStories[userIndex][storyIndex]["story_duration"],
                  ),
                  _displayStories[userIndex][storyIndex]["story_media"],
                  controller: controller,
                  caption: Text(
                    _displayStories[userIndex][storyIndex]["caption"] ?? "",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : StoryItem.pageImage(
                  duration: Duration(
                    milliseconds:
                        _displayStories[userIndex][storyIndex]["story_duration"],
                  ),
                  caption: Text(
                    _displayStories[userIndex][storyIndex]["caption"] ?? "",
                    style: TextStyle(color: Colors.white),
                  ),
                  controller: controller,
                  url: _displayStories[userIndex][storyIndex]["story_media"],
                );
          });

          return StoryView(
            controller: controller,
            repeat: false,
            onStoryShow: (storyItem, storyIndex) {
              markAsViewedByCurrentUser();
            },
            onComplete: () {
              if (_pageController.page?.round() == _displayStories.length - 1) {
                Navigator.of(context).pop();
              } else {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              }
            },
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Navigator.pop(context);
              }
            },
            storyItems: storyItems,
          );
        }),
      ),
    );
  }
}
