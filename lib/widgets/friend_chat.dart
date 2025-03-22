import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class FriendChat extends StatelessWidget {
  final String firendPhoto;
  final String friendName;
  final String lastMessage;
  const FriendChat({
    super.key,
    required this.firendPhoto,
    required this.friendName,
    required this.lastMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            width: 100.w,
            height: 13.h,
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
                          child: Image.network(firendPhoto),
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
                              lastMessage,
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
