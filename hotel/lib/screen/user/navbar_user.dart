import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hotel/provider/user.dart';
import 'package:hotel/screen/together/acount_page.dart';
import 'package:hotel/screen/user/home_page_user.dart';
import 'package:hotel/screen/user/notification.dart';
import 'package:hotel/screen/user/rollcall_screen.dart';
import 'package:hotel/widget/notification.dart';
import 'package:provider/provider.dart';

class NavbarUser extends StatefulWidget {
  const NavbarUser({super.key});

  @override
  State<NavbarUser> createState() => _NavbarUserState();
}

class _NavbarUserState extends State<NavbarUser> {
  int _bottomNavIndex = 0;

  final tab = [
    const HomePageUser(),
    RollcallScreen(),
    NotificationScreen(),
    const AccountPage()
  ];

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NavbarUser(),
          ));
    }
  }

  Future<void> setupInteractedMessage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    debugPrint(token);
    await FirebaseFirestore.instance
        .collection("User")
        .doc(userProvider.getData().id)
        .update({"fcm_token": token});
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
          'Received a foreground message: ${message.notification?.body}');
      NotificationService().showNotification(
          title: message.notification?.title, body: message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tab[_bottomNavIndex],
      bottomNavigationBar: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: GNav(
          gap: 10,
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          activeColor: Colors.blueAccent,
          iconSize: 26,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.white,
          color: Colors.black,
          tabs: [
            GButton(
              icon: Icons.home_outlined,
              text: 'Trang chủ',
            ),
            GButton(
              icon: Icons.calendar_month_outlined,
              text: 'Chấm công',
            ),
            GButton(
              icon: Icons.notifications_outlined,
              text: 'Thông báo',
            ),
            GButton(
              icon: Icons.person_outline,
              text: 'Tài khoản',
            ),
          ],
          selectedIndex: _bottomNavIndex,
          onTabChange: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
          },
        ),
      ),
    );
  }
}
