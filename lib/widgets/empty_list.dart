import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  const EmptyList({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    // Defining the image and text for each type
    final Map<String, Map<String, String>> typeData = {
      'wishlist': {
        'image': 'assets/images/wishlist_illustration.png',
        'text': 'Votre wishlist est vide',
      },
      'car': {
        'image': 'assets/images/car_illustration.png',
        'text': 'Aucune voiture dans cette destination',
      },
      'house': {
        'image': 'assets/images/house_illustration.png',
        'text': 'Aucune maison dans cette destination',
      },
      'trip': {
        'image': 'assets/images/trip_illustration.png',
        'text': 'Aucun voyage prévu dans cette destination',
      },
    };

    // Get the data for the given type, or fall back to a default
    final image =
        typeData[type]?['image'] ?? 'assets/images/wishlist_illustration.png';
    final text = typeData[type]?['text'] ?? 'No items available';

    // Adjust size based on type
    final double imageSize = type == 'wishlist' ? 300 : 200;
    final double textSize = type == 'wishlist' ? 22 : 18;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: imageSize,
              height: imageSize,
              child: Image.asset(image),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xff001939),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'KastelovAxiforma',
                  fontSize: textSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
