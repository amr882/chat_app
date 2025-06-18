// ignore: library_prefixes
import 'package:chat_app/auth/keys.dart' as Utilis;
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({super.key});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: Utilis.AppId,
        appSign: Utilis.Appsign,
        callID: "mpawkmfpo5465",
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),

        userID: "lmlamd55444545",
        userName: 'User_lmlamd55444545',
      ),
    );
  }
}
