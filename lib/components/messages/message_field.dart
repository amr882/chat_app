import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  const MessageField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,

      style: GoogleFonts.rubik(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Type your message..",
        hintStyle: TextStyle(color: Color(0xff4d4c4e)),
        filled: true,
        fillColor: Color(0xff272828),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
