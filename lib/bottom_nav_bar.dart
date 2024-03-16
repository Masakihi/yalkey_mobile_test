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
import 'dart:async';

class BottomNavBar extends StatefulWidget {
  final int initialScreenIndex;
  const BottomNavBar({Key? key, this.initialScreenIndex = 0}) : super(key: key);

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

  int? _notificationCount;

  Future<void> _fetchNotificationData() async {
    // try {
    final dynamic response =
        await httpGet('new-notification-count/', jwt: true);
    //print("通知の読み込み");
    //print(response);
    if (mounted) {
      // ウィジェットがまだウィジェットツリーに存在する場合にのみsetState()を呼び出す
      setState(() {
        _notificationCount = response['new_notification_count'];
      });
    }
    // } catch (error) {
    //   print('Error fetching notification data: $error');
    // }
  }

  @override
  void initState() {
    super.initState();

    // 受け取ったデータを状態を管理する変数に格納
    _fetchNotificationData();
    //print(_notificationCount);
    // 60秒ごとにデータを更新するためのTimerをセットアップ
    Timer.periodic(Duration(seconds: 60), (timer) {
      _fetchNotificationData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller:
          PersistentTabController(initialIndex: widget.initialScreenIndex),
      screens: _screens,
      items: [
        PersistentBottomNavBarItem(
          icon: Icon(Icons.home),
          title: null,
          activeColorPrimary: const Color(0xFFAE0103), // 選択時のアイコンの色
          inactiveColorPrimary: Colors.white, // 非選択時のアイコンの色
        ),
        PersistentBottomNavBarItem(
          icon: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications),
                  // 通知バッジを表示する
                  if (_notificationCount != null && _notificationCount != 0)
                    Positioned(
                      top: -10,
                      right: -10,
                      child: badges.Badge(
                        badgeContent: Text('${_notificationCount!}',
                            style: TextStyle(fontSize: 10)),
                        badgeAnimation: const badges.BadgeAnimation.rotation(
                          animationDuration: Duration(seconds: 1),
                          colorChangeAnimationDuration: Duration(seconds: 1),
                          loopAnimation: false,
                          curve: Curves.fastOutSlowIn,
                          colorChangeAnimationCurve: Curves.easeInCubic,
                        ),
                        badgeStyle: const badges.BadgeStyle(
                            badgeColor: Color(0xFFAE0103),
                            padding: EdgeInsets.all(7)),
                      ),
                    ),
                ],
              ),
            ],
          ),
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
