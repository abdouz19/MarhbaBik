import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard(
      {super.key,
      required this.imagePath,
      required this.valueColor1,
      required this.planName,
      required this.price,
      required this.texts,
      required this.textColor,
      required this.valueColor2});

  final String imagePath;
  final int valueColor1;
  final int valueColor2;
  final String planName;
  final double price;
  final List<String> texts;
  final int textColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [
            Color(valueColor1),
            Color(valueColor2),
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              children: [
                Image.asset(
                  imagePath,
                  width: 35,
                  height: 35,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  planName,
                  style: TextStyle(
                    fontFamily: 'KastelovAxiforma',
                    fontSize: 20,
                    color: Color(textColor),
                  ),
                )
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$price DZD / month',
                style: const TextStyle(
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.check, size: 11, color: Color(valueColor1)),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    texts[0],
                    style: const TextStyle(
                      fontFamily: 'KastelovAxiforma',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.check, size: 11, color: Color(valueColor1)),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    texts[1],
                    style: const TextStyle(
                      fontFamily: 'KastelovAxiforma',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
