// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:io';

import 'package:chat_app/components/caption_field.dart';
import 'package:chat_app/services/stories_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmer extends StatefulWidget {
  final File file;

  const VideoTrimmer(this.file, {super.key});

  @override
  _VideoTrimmerState createState() => _VideoTrimmerState();
}

class _VideoTrimmerState extends State<VideoTrimmer> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? value;

    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (String? outputPath) {
        value = outputPath;
      },
    );

    return value;
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();

    _loadVideo();
  }

  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoViewer(trimmer: _trimmer),
              _isPlaying
                  ? Container()
                  : Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(111, 19, 24, 28),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 50.0,
                      color: Colors.white,
                    ),
                  ),
            ],
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: Builder(
            builder:
                (context) => Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 19, 24, 28),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 3.h,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Center(
                            child: TrimViewer(
                              trimmer: _trimmer,
                              viewerHeight: 50.0,
                              showDuration: false,
                              viewerWidth: MediaQuery.of(context).size.width,
                              maxVideoLength: const Duration(seconds: 30),
                              onChangeStart: (value) => _startValue = value,
                              onChangeEnd: (value) => _endValue = value,
                              onChangePlaybackState: (value) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted) {
                                    setState(() => _isPlaying = value);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());

                            bool playbackState = await _trimmer
                                .videoPlaybackControl(
                                  startValue: _startValue,
                                  endValue: _endValue,
                                );
                            setState(() {
                              _isPlaying = playbackState;
                            });
                          },
                        ),
                      ),

                      Container(
                        width: 100.w,
                        height: 13.h,
                        decoration: BoxDecoration(
                          color: Color(0xff323741),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: CaptionField(controller: controller),
                              ),
                              GestureDetector(
                                onTap:
                                    _progressVisibility
                                        ? null
                                        : () async {
                                          final outputPath = await _saveVideo();
                                          if (outputPath != null) {
                                            print('OUTPUT PATH: $outputPath');
                                            File outputFile = File(outputPath);
                                            Provider.of<StoriesServices>(
                                              context,
                                              listen: false,
                                            ).uploadToStorage(
                                              outputFile,
                                              controller.text,
                                            );

                                            Navigator.of(context).pop();
                                          }
                                        },
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Color(0xff7c01f6),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: SvgPicture.asset(
                                    "assets/send_story.svg",
                                    height: 3.5.h,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
