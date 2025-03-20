import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CustomTextField extends StatefulWidget {
  final Key formState;
  final bool obscureText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final String hintText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  const CustomTextField({
    super.key,
    required this.formState,
    required this.obscureText,
    required this.controller,
    required this.textInputType,
    required this.hintText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formState,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        child: TextFormField(
          style: GoogleFonts.rubik(color: const Color.fromARGB(255, 0, 0, 0)),
          cursorColor: Colors.black,
          obscureText: widget.obscureText,
          controller: widget.controller,
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            suffixIcon: widget.suffixIcon,
            prefixIcon: Container(
              padding: EdgeInsets.all(1.5.h),
              height: 2.h,
              width: 4.w,
              child: widget.prefixIcon,
            ),
            filled: true,
            fillColor: Color(0xfff2f2f2),
            hintStyle: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.w400,
              fontSize: 1.8.h,
            ),
            border: OutlineInputBorder(),

            // focused
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.transparent),
            ),

            // unfocused
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            hintText: widget.hintText,
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}
