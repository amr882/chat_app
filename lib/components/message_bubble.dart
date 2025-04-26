import 'package:flutter/material.dart';
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
    return Container(
      padding: EdgeInsets.all(10),

      margin: EdgeInsets.only(left: 15.w, right: 5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [0.7, 02],
          colors: [Color(0xff8818f8), Color(0xffa650fc)],
        ),
      ),
      child: Text(message, style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,)),
    );
  }
}
