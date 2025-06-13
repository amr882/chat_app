import 'package:chat_app/view/nav_bar_pages.dart/home_page.dart';
import 'package:chat_app/view/nav_bar_pages.dart/call_hestory.dart';
import 'package:chat_app/view/nav_bar_pages.dart/setting_page.dart';
import 'package:chat_app/view/nav_bar_pages.dart/stories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int currentPageIndex = 0;
  List pages = [HomePage(), CallHestory(), StoriesPage(), SettingPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox(width: 100.w, height: 100.h, child: pages[currentPageIndex]),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 8.h,

                margin: EdgeInsets.symmetric(horizontal: 9.w, vertical: 1.h),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xff252525),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory: NoSplash.splashFactory,

                    highlightColor: Colors.transparent,
                  ),
                  child: NavigationBar(
                    indicatorColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysHide,
                    onDestinationSelected: (value) {
                      setState(() {
                        currentPageIndex = value;
                      });
                    },
                    selectedIndex: currentPageIndex,
                    destinations: [
                      NavigationDestination(
                        icon: _buildSvgIcon("assets/Chat.svg", 0),
                        label: "",
                      ),
                      NavigationDestination(
                        icon: _buildSvgIcon("assets/Call.svg", 1),
                        label: "",
                      ),
                      NavigationDestination(
                        icon: _buildSvgIcon("assets/stories.svg", 2),
                        label: "",
                      ),
                      NavigationDestination(
                        icon: _buildSvgIcon("assets/Setting.svg", 3),
                        label: "",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSvgIcon(String assetPath, int index) {
    Color iconColor =
        currentPageIndex == index ? Color(0xff7c01f6) : Color(0xff4d4c4e);

    return SvgPicture.asset(
      assetPath,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
