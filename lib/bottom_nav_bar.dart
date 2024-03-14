import 'package:flutter/material.dart';
import 'api.dart';
import 'notification/notification_list.dart';
import 'home_page.dart';
import 'notification/notification.dart';
import 'post/post_page.dart';
import 'profile/profile_page.dart';
import 'mission/mission_list.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:badges/badges.dart' as badges;


class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<Widget> _screens = [
    const HomePage(),
    const NotificationListPage(),
    const MissionListPage(),
    const ProfilePage(),
  ];

  Future<dynamic>? _nofiticationCount;


  Future<void> _fetchNotificationData() async {
    try {
      final Future<dynamic> response =
      httpGet('new-notification-count/', jwt: true);
      print(response);
      setState(() {
        _nofiticationCount = response;
      });
    } catch (error) {
      print('Error fetching notification data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // 受け取ったデータを状態を管理する変数に格納
    _fetchNotificationData();
    print(_nofiticationCount);
  }



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
          activeColorPrimary: const Color(0xFFAE0103), // 選択時のアイコンの色
          inactiveColorPrimary: Colors.white, // 非選択時のアイコンの色
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.notifications),
          title: null,
          activeColorPrimary: const Color(0xFFAE0103),
          inactiveColorPrimary: Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.task),
          title: null,
          activeColorPrimary: const Color(0xFFAE0103),
          inactiveColorPrimary: Colors.white,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.person),
          title: null,
          activeColorPrimary: const Color(0xFFAE0103),
          inactiveColorPrimary: Colors.white,
        ),
      ],
      decoration: NavBarDecoration(
        //colorBehindNavBar: Colors.black12,
        colorBehindNavBar: Colors.transparent,
        borderRadius: BorderRadius.circular(0.0),
      ),
      confineInSafeArea: true,
      backgroundColor: const Color(0xFF1A1A1A),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      bottomScreenMargin: 50.0,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: NavBarStyle.style6,
    );
  }
}
