import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UserStoryCard extends StatelessWidget {
  final String userPhoto;
  final String userName;
  final String uploadDate;
  const UserStoryCard({
    super.key,
    required this.userPhoto,
    required this.userName,
    required this.uploadDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 4.w),
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.red,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(userPhoto, height: 8.h, width: 8.h),
            ),
            SizedBox(width: 10.w),
            Text("$userName\n$uploadDate"),
          ],
        ),
      ),
    );
  }
}
