// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chat_app/view/story_trimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class StoriesServices extends ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final dateTime = Timestamp.now().microsecondsSinceEpoch;

  bool _isLoading = false;
  final List<List<Map<String, dynamic>>> _storiseList = [];
  bool get isLoading => _isLoading;
  List<List<Map<String, dynamic>>> get storiesList => _storiseList;

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
  uploadToStorage(
    File? outputFile,
    String? controllerText,
    String storyType,
    Duration storyDuration,
  ) async {
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
    uploadToFirestore(
      publicUrl,
      controllerText ?? "",
      storyType,
      storyDuration,
    );
    print("story uploaded to firebase");

    print("Story uploaded successfully! Public URL: $publicUrl");
    return publicUrl;
  }

  // add story to firebase firestore

  uploadToFirestore(
    String storyMedia,
    String caption,
    String storyType,
    Duration storyDuration,
  ) async {
    var uuid = Uuid();
    final storyId = uuid.v4();
    final docRef = firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid);
    Map<String, dynamic> userData = {};
    await docRef.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      userData = data;
    });

    await firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .collection("stories")
        .doc(storyId)
        .set({
          "uploading_date": dateTime,
          "story_media": storyMedia,
          "story_id": storyId,
          "caption": caption,
          "userName": userData["Uname"],
          "pfp": userData["pfp"],
          "UserId": firebaseAuth.currentUser!.uid,
          "story_type": storyType,
          "viewers": [],
          "story_duration": storyDuration.inMilliseconds,
        });
    setLoadingState(false);
    notifyListeners();
  }

  // get list of stories from all user within 1 day of uploading
  Future<List<List<Map<String, dynamic>>>> getStories() async {
    setLoadingState(true);

    final twentyHoursAgo =
        DateTime.now()
            .subtract(const Duration(hours: 24))
            .microsecondsSinceEpoch;
    List<List<Map<String, dynamic>>> groupedStoriesList = [];
    Map<String, List<Map<String, dynamic>>> userStoriesMap = {};
    String? currentUserId = firebaseAuth.currentUser?.uid;

    if (currentUserId != null) {
      QuerySnapshot currentUserStoriesSnapshot =
          await firebaseFirestore
              .collection("users")
              .doc(currentUserId)
              .collection("stories")
              .where("uploading_date", isGreaterThan: twentyHoursAgo)
              .get();

      if (currentUserStoriesSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> currentUserStories = [];
        for (QueryDocumentSnapshot storyDocument
            in currentUserStoriesSnapshot.docs) {
          currentUserStories.add(storyDocument.data() as Map<String, dynamic>);
        }
        groupedStoriesList.add(currentUserStories);
        userStoriesMap[currentUserId] = currentUserStories;
      }
    }

    QuerySnapshot allStoriesSnapshot =
        await firebaseFirestore
            .collectionGroup("stories")
            .where("uploading_date", isGreaterThan: twentyHoursAgo)
            .get();

    for (QueryDocumentSnapshot storyDocument in allStoriesSnapshot.docs) {
      Map<String, dynamic> storyData =
          storyDocument.data() as Map<String, dynamic>;
      String userId = storyDocument.reference.parent.parent!.id;

      if (currentUserId == null || userId != currentUserId) {
        if (!userStoriesMap.containsKey(userId)) {
          userStoriesMap[userId] = [];
        }
        userStoriesMap[userId]!.add(storyData);
      }
    }
    userStoriesMap.forEach((userId, stories) {
      if (currentUserId == null || userId != currentUserId) {
        groupedStoriesList.add(stories);
      }
    });

    setLoadingState(false);
    print(groupedStoriesList);
    return groupedStoriesList;
  }

  markAsViewed(String uploaderId, String storyId) async {
    await firebaseFirestore
        .collection("users")
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((value) {
          var userData = value.data();
          print(userData);
          firebaseFirestore
              .collection("users")
              .doc(uploaderId)
              .collection("stories")
              .doc(storyId)
              .update({
                "viewers": FieldValue.arrayUnion([userData]),
              });
        });
  }
}
