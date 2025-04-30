import 'package:flutter/material.dart';

class MessageField extends StatelessWidget {
  final TextEditingController controller;
  const MessageField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, autofocus: true);
  }
}
