import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoriesServices {
  // upload storie from storage

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

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "stories/$fileName";
    await Supabase.instance.client.storage
        .from("chatpfp")
        .upload(path, storyFile!);

    final String publicUrl = Supabase.instance.client.storage
        .from('chatpfp')
        .getPublicUrl(path);

    print("Story uploaded successfully! Public URL: $publicUrl");
    return publicUrl;
  }
}


  // DateTime dateTime = DateTime.now();