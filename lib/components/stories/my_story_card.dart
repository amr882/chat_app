import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MyStoryCard extends StatelessWidget {
  final String userPhoto;
  const MyStoryCard({super.key, required this.userPhoto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 2.w),
      child: Container(
        padding: EdgeInsets.all(10),

        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(userPhoto, height: 8.h, width: 8.h),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Color(0xff7c01f6),
                  ),
                  width: 30,
                  height: 30,
                  child: Icon(Icons.add, color: Colors.white, size: 2.4.h),
                ),
              ],
            ),
            SizedBox(width: 3.w),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My stories",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 1.6.h,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "tap to add stories update",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 1.4.h,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
