import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileBar extends StatelessWidget {
  const ProfileBar({super.key, required this.firstName,this.lastName = '', required this.profilePicture});

  final String profilePicture;
  final String lastName;
  final String firstName;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xff001939).withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        Row(
          children: [
            ClipOval(
              child: profilePicture.isNotEmpty
                  ? CachedNetworkImage(
                    imageUrl: profilePicture,
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/placeholder.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text('Hébergé par $firstName $lastName'),
              ),
            ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xff001939).withOpacity(0.1),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ],
    );
  }
}
