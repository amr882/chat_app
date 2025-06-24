import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoriesServices {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  DateTime dateTime = DateTime.now();
  // pick stories from local storage
  File? storyFile;
  pickStory() async {
    FilePicker filePicker = FilePicker.platform;
    FilePickerResult? result = await filePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null) return;
    storyFile = File(result.files.single.path!);
    await uploadToStorage();
  }

  // upload story to Supabase
  uploadToStorage() async {
    if (storyFile == null) return;

    final fileName = dateTime.millisecondsSinceEpoch.toString();
    final path = "stories/$fileName";
    await Supabase.instance.client.storage
        .from("chatpfp")
        .upload(path, storyFile!);

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
    var r = Random();
    String storyId = String.fromCharCodes(
      List.generate(20, (index) => r.nextInt(33) + 89),
    );
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
  }

  // get list of stories from all user withthen 1 day of uploading
  Future<List<Map<String, dynamic>>> getStrories() async {
    DateTime twentyHoursAgo = DateTime.now().subtract(Duration(days: 1));
    List<Map<String, dynamic>> usersStories = [];
    QuerySnapshot storiesSnapshot =
        await firebaseFirestore
            .collectionGroup("stories")
            .where("uploading_date", isGreaterThan: twentyHoursAgo)
            .get();
    print(storiesSnapshot);

    for (QueryDocumentSnapshot storyData in storiesSnapshot.docs) {
      usersStories.add(storyData.data() as Map<String, dynamic>);
    }
    print(usersStories);
    return usersStories;
  }
}
