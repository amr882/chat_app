import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CaptionField extends StatefulWidget {
  final TextEditingController controller;
  const CaptionField({super.key, required this.controller});

  @override
  State<CaptionField> createState() => _CaptionFieldState();
}

class _CaptionFieldState extends State<CaptionField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,

      controller: widget.controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xff2a2f39),

        hintStyle: TextStyle(
          color: const Color.fromARGB(188, 255, 255, 255),
          fontWeight: FontWeight.w400,
          fontSize: 1.8.h,
        ),
        border: OutlineInputBorder(),

        // focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Colors.transparent),
        ),

        // unfocused
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        hintText: "add a caption",
      ),
    );
  }
}
