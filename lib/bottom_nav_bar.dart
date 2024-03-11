import 'package:flutter/material.dart';
import 'notification/notification_list.dart';
import 'home_page.dart';
import 'notification/notification.dart';
import 'post_page.dart';
import 'profile/profile_page.dart';
import 'mission/mission_list.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<Widget> _screens = [
    const HomePage(),
    const NotificationListPage(),
    const PostPage(),
    const MissionListPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: PersistentTabController(initialIndex: 0),
      screens: _screens,
      items: [
        PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          title: null,
          activeColorPrimary: Colors.red, // 選択時のアイコンの色
          inactiveColorPrimary: Colors.white, // 非選択時のアイコンの色
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.notifications),
          title: null,
          activeColorPrimary: Colors.red,
          inactiveColorPrimary: Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.post_add),
          title: null,
          activeColorPrimary: Colors.red,
          inactiveColorPrimary: Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.task),
          title: null,
          activeColorPrimary: Colors.red,
          inactiveColorPrimary: Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.person),
          title: null,
          activeColorPrimary: Colors.red,
          inactiveColorPrimary: Colors.white,
        ),
      ],
      decoration: NavBarDecoration(
        colorBehindNavBar: Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      confineInSafeArea: true,
      backgroundColor: Colors.black,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      bottomScreenMargin: 0.0,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style6,
    );
  }
}
