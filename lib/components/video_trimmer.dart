// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,

      body: Builder(
        builder:
            (context) => Center(
              child: Container(
                padding: EdgeInsets.only(bottom: 30.0),
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 7.h),
                    Row(
                      children: [
                        SizedBox(width: 7.w),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 66, 66, 66),
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
                    SizedBox(height: 2.h),
                    Visibility(
                      visible: _progressVisibility,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.red,
                      ),
                    ),

                    GestureDetector(
                      child: Center(
                        child: TrimViewer(
                          trimmer: _trimmer,
                          viewerHeight: 50.0,
                          showDuration: false,
                          viewerWidth: MediaQuery.of(context).size.width,
                          maxVideoLength: const Duration(seconds: 30),
                          onChangeStart: (value) => _startValue = value,
                          onChangeEnd: (value) => _endValue = value,
                          onChangePlaybackState: (value) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() => _isPlaying = value);
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          bool playbackState = await _trimmer
                              .videoPlaybackControl(
                                startValue: _startValue,
                                endValue: _endValue,
                              );
                          setState(() {
                            _isPlaying = playbackState;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoViewer(trimmer: _trimmer),
                            _isPlaying
                                ? Container()
                                : Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      181,
                                      119,
                                      119,
                                      119,
                                    ),
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
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap:
                                _progressVisibility
                                    ? null
                                    : () async {
                                      _saveVideo().then((outputPath) {
                                        print('OUTPUT PATH: $outputPath');
                                        final snackBar = SnackBar(
                                          content: Text(
                                            'Video Saved successfully',
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(snackBar);
                                      });
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
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
