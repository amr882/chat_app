import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_regex/flutter_regex.dart';
import 'package:sizer/sizer.dart';

class MessageBubble extends StatelessWidget {
  final bool uSender;
  final String message;
  const MessageBubble({
    super.key,
    required this.uSender,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        print("pressed ++++++++++++++++++++$message");
      },
      child:
          message.toString().isUrl()
              ? Container(
                height: 30.h,
                margin: EdgeInsets.only(
                  left: uSender ? 15.w : 5.w,
                  right: uSender ? 5.w : 15.w,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: message,
                    placeholder:
                        (context, url) => SizedBox(
                          height: 30.h,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                    errorWidget:
                        (context, url, error) => Text(
                          message,
                          style: TextStyle(
                            color: uSender ? Colors.white : Color(0xffbababa),
                            fontWeight: FontWeight.w500,
                            fontSize: 2.h,
                          ),
                        ),
                    fit: BoxFit.cover,
                  ),
                ),
              )
              : Container(
                padding: EdgeInsets.all(8),

                margin: EdgeInsets.only(
                  left: uSender ? 15.w : 5.w,
                  right: uSender ? 5.w : 15.w,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.7, 02],
                    colors:
                        uSender
                            ? [Color(0xff8818f8), Color(0xffa650fc)]
                            : [Color(0xff1f1f1f), Color(0xff1f1f1f)],
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: uSender ? Colors.white : Color(0xffbababa),
                    fontWeight: FontWeight.w500,
                    fontSize: 2.h,
                  ),
                ),
              ),
    );
  }
}
