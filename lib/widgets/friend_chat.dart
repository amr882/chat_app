import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class FriendChat extends StatelessWidget {
  final String firendPhoto;
  final String friendName;
  final String lastMessage;

  final String lastMessageTime;
  const FriendChat({
    super.key,
    required this.firendPhoto,
    required this.friendName,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.7, 02],
            colors: [Color(0xff454546), Color(0xff272627)],
          ),
        ),
        padding: EdgeInsets.all(1),
        child: Center(
          child: Container(
            width: 94.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: Color(0xff1f1f1f),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // profile Photo and Uname
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            "https://tjfiyddgeljrygtjgyov.supabase.co/storage/v1/object/public/chatpfp/uploads/userpfp.jpg",
                            fit: BoxFit.cover,
                            width: 8.h,
                            height: 8.h,
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friendName.replaceFirst(
                                friendName[0],
                                friendName[0].toUpperCase(),
                              ),
                              style: GoogleFonts.rubik(
                                color: Color(0xffc8c8c8),
                                fontSize: 1.5.h,
                              ),
                            ),

                            SizedBox(height: 10),
                            Text(
                              lastMessage.length <= 20
                                  ? lastMessage
                                  : "${lastMessage.substring(0, 20)}...",

                              style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontSize: 1.6.h,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      lastMessageTime,
                      style: TextStyle(
                        color: Color(0xff7c01f6),
                        fontWeight: FontWeight.w700,
                        fontSize: 3.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
