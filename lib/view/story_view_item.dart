import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryViewItem extends StatefulWidget {
  final StoryController storyController;
  final void Function(StoryItem, int)? onStoryShow;
  final void Function()? onComplete;
  final List<StoryItem?> storyItems;

  const StoryViewItem({
    super.key,
    required this.storyController,
    this.onStoryShow,
    this.onComplete,
    required this.storyItems,
  });

  @override
  State<StoryViewItem> createState() => _StoryViewItemState();
}

class _StoryViewItemState extends State<StoryViewItem> {
  @override
  Widget build(BuildContext context) {
    return StoryView(
      controller: widget.storyController,
      repeat: false,
      onStoryShow: widget.onStoryShow,
      onComplete: widget.onComplete,
      onVerticalSwipeComplete: (direction) {
        if (mounted) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        }
      },
      storyItems: widget.storyItems,
    );
  }
}
