import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/screens/shared/messages_screen.dart';
import 'package:marhba_bik/screens/traveler/explore_traveler.dart';
import 'package:marhba_bik/screens/traveler/houses_traveler.dart';
import 'package:marhba_bik/screens/traveler/profile_traveler.dart';
import 'package:marhba_bik/screens/traveler/wishlist_traveler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TravelerHomeScreen extends StatefulWidget {
  const TravelerHomeScreen({super.key});

  @override
  State<TravelerHomeScreen> createState() {
    return _TravelerHomeScreenState();
  }
}

class _TravelerHomeScreenState extends State<TravelerHomeScreen> {
  int index = 0;

  final screens = [
    const HousesTraveler(),
    const ExploreTraveler(),
    const WishlistTraveler(),
    MessagesScreen(),
    const ProfileTraveler(),
  ];

  Icon _buildIcon(IconData iconData, int iconSize, bool selected) {
    return Icon(
      iconData,
      size: iconSize.toDouble(),
      color: selected
          ? const Color(0xff3F75BB)
          : const Color.fromARGB(255, 173, 173, 173),
    );
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
                ? _buildIcon(Icons.house_rounded, 40, true)
                : _buildIcon(Icons.house_outlined, 30, false),
            index == 1
                ? _buildIcon(Icons.search_rounded, 40, true)
                : _buildIcon(Icons.search_outlined, 30, false),
            index == 2
                ? _buildIcon(MdiIcons.heart, 40, true)
                : _buildIcon(MdiIcons.heartOutline, 30, false),
            index == 3
                ? _buildIcon(MdiIcons.message, 40, true)
                : _buildIcon(MdiIcons.messageOutline, 30, false),
            index == 4
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
