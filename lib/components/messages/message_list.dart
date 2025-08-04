import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MessageList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> children;
  final void Function() scrollDown;
  const MessageList({
    super.key,
    required this.scrollController,
    required this.children,
    required this.scrollDown,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: scrollController,
          physics: BouncingScrollPhysics(),
          children:
              //
              children,
        ),
        Positioned(
          bottom: 1.h,
          left: 2.w,
          child: GestureDetector(
            onTap: scrollDown,
            child: Container(
              width: 30,
              height: 30,

              decoration: BoxDecoration(
                color: Color(0xff1f1f1f),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Icon(
                  Icons.keyboard_double_arrow_down_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
