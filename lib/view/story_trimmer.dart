import 'dart:io';

import 'package:chat_app/components/image_crop.dart';
import 'package:chat_app/components/video_trimmer.dart';
import 'package:flutter/material.dart';

class StoryTrimmer extends StatelessWidget {
  final bool isVideo;
  final File file;
  const StoryTrimmer({super.key, required this.isVideo, required this.file});

  @override
  Widget build(BuildContext context) {
    return isVideo ? VideoTrimmer(file) : ImageCrop(pickedImage: file);
  }
}
