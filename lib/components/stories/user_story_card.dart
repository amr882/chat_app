import 'package:chat_app/components/stories/story_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UserStoryCard extends StatelessWidget {
  final String userPhoto;
  final String userName;
  final String uploadDate;
  final int totalStoriesLength;
  final int storyViewedCount;
  const UserStoryCard({
    super.key,
    required this.userPhoto,
    required this.userName,
    required this.uploadDate,
    required this.totalStoriesLength,
    required this.storyViewedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 2.w),
      child: Container(
        width: 100.w,
        padding: EdgeInsets.all(10),

        child: Row(
          children: [
            PieChart(
              data: List.generate(totalStoriesLength, (index) {
                print(100 / totalStoriesLength);
                bool viewedStory = index >= storyViewedCount;
                return PieChartData(
                  viewedStory ? Color(0xff7c01f6) : Color(0xff4d4c4e),
                  100 / totalStoriesLength,
                );
              }),
              radius: 100,
              oneStory: totalStoriesLength == 1,
              child: Container(
                padding: EdgeInsets.all(3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(userPhoto, height: 8.h, width: 8.h),
                ),
              ),
            ),
            SizedBox(width: 3.w),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 1.6.h,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  uploadDate,
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
