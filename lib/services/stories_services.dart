// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:chat_app/view/story_trimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StoriesServices extends ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  DateTime dateTime = DateTime.now();

  bool _isLoading = false;
  final List<Map<String, dynamic>> _storiseList = [];
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get storiesList => _storiseList;

  void setLoadingState(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // pick stories from local storage
  File? storyFile;
  Future<void> pickStory(BuildContext context) async {
    setLoadingState(true);
    bool? isVideo;
    FilePicker filePicker = FilePicker.platform;
    FilePickerResult? result = await filePicker.pickFiles(
      type: FileType.any,

      allowMultiple: false,
    );
    if (result == null) {
      setLoadingState(false);
      return;
    }

    PlatformFile file = result.files.first;
    storyFile = File(result.files.single.path!);

    if (file.extension != null) {
      final String lowerCaseExtension = file.extension!.toLowerCase();
      if ([
        'jpg',
        'jpeg',
        'png',
        'gif',
        'bmp',
        'webp',
      ].contains(lowerCaseExtension)) {
        isVideo = false;
        print('Picked file is an IMAGE.');
      } else if ([
        'mp4',
        'mov',
        'avi',
        'mkv',
        'webm',
      ].contains(lowerCaseExtension)) {
        print('Picked file is a VIDEO.');
        isVideo = true;
      } else {
        print(
          'Picked file is neither a common image nor video type by extension.',
        );
      }
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryTrimmer(isVideo: isVideo!, file: storyFile!),
      ),
    );
  }

  // upload story to Supabase
  uploadToStorage(File? outputFile) async {
    if (outputFile == null) {
      setLoadingState(false);
      return;
    }
    var uuid = Uuid();
    final fileName = uuid.v4();
    final path = "stories/$fileName";
    await Supabase.instance.client.storage
        .from("chatpfp")
        .upload(path, outputFile);

    final String publicUrl = Supabase.instance.client.storage
        .from('chatpfp')
        .getPublicUrl(path);
    uploadToFirestore(publicUrl);
    print("story uploaded to firebase");

    print("Story uploaded successfully! Public URL: $publicUrl");
    return publicUrl;
  }

  // add story to firebase firestore

  uploadToFirestore(String storyData) async {
    // gerating a random id for story
    var uuid = Uuid();
    final storyId = uuid.v4();
    // updating story data on firebase firestore
    await firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("stories")
        .doc(storyId)
        .set({
          "uploading_date": dateTime,
          "story_data": storyData,
          "story_id": storyId,
        });
    setLoadingState(false);
    notifyListeners();
  }

  // get list of stories from all user withthen 1 day of uploading
  Future<List<Map<String, dynamic>>> getStrories() async {
    setLoadingState(true);
    DateTime twentyHoursAgo = DateTime.now().subtract(Duration(days: 1));

    QuerySnapshot storiesSnapshot =
        await firebaseFirestore
            .collectionGroup("stories")
            .where("uploading_date", isGreaterThan: twentyHoursAgo)
            .get();
    print(storiesSnapshot);

    for (QueryDocumentSnapshot storyData in storiesSnapshot.docs) {
      storiesList.add(storyData.data() as Map<String, dynamic>);
      notifyListeners();
    }
    print(storiesList);
    setLoadingState(false);
    notifyListeners();
    return storiesList;
  }
}
