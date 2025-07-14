import 'dart:io';

import 'package:croppy/croppy.dart';
import 'package:flutter/material.dart';

class ImageCrop extends StatefulWidget {
  final File pickedImage;
  const ImageCrop({super.key, required this.pickedImage});

  @override
  State<ImageCrop> createState() => _ImageCropState();
}

class _ImageCropState extends State<ImageCrop> {
  @override
  void initState() {
    body();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center());
  }

  body() async {
    final result = await showCupertinoImageCropper(
      context,
      imageProvider: FileImage(widget.pickedImage),
    );
    if (result == null) {
      Navigator.of(context).pop();
    } else {
      print(result.uiImage);
    }
  }
}
