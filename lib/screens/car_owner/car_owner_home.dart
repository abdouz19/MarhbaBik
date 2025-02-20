import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/screens/car_owner/offers_car_owner.dart';
import 'package:marhba_bik/screens/car_owner/profile_car_owner.dart';
import 'package:marhba_bik/screens/shared/messages_screen.dart';

class CarOwnerHomeScreen extends StatefulWidget {
  const CarOwnerHomeScreen({super.key});

  @override
  State<CarOwnerHomeScreen> createState() {
    return _CarOwnerHomeScreenState();
  }
}

class _CarOwnerHomeScreenState extends State<CarOwnerHomeScreen> {
  int index = 1;

  final screens = [
    MessagesScreen(),
    const CarOwnerOffers(),
    const CarOwnerProfile()
  ];

  Icon _buildIcon(IconData iconData, int iconSize, bool selected) {
    return Icon(
      iconData,
      size: iconSize.toDouble(),
      color: selected ? const Color(0xff3F75BB) : const Color(0xff828181),
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Notification Title: ${message.notification?.title}');
        print('Notification Body: ${message.notification?.body}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['booking_id'] != null) {
        Navigator.pushNamed(context, '/booking_details',
            arguments: message.data['booking_id']);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          height: 60,
          backgroundColor: Colors.transparent,
          items: <Widget>[
            index == 0
                ? _buildIcon(Icons.message_rounded, 40, true)
                : _buildIcon(Icons.message_outlined, 30, false),
            index == 1
                ? _buildIcon(Icons.add_rounded, 40, true)
                : _buildIcon(Icons.add_outlined, 30, false),
            index == 2
                ? _buildIcon(Icons.person_rounded, 40, true)
                : _buildIcon(Icons.person_outline, 30, false),
          ],
          index: index,
          onTap: (index) => setState(() => this.index = index),
        ),
      ),
    );
  }
}
