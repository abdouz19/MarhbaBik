import 'package:flutter/material.dart';

class SubscriptionHeader extends StatelessWidget {
  const SubscriptionHeader(
      {super.key,
      required this.planName,
      required this.valueColor1,
      required this.valueColor2,
      required this.price});

  final int valueColor1;
  final int valueColor2;
  final double price;
  final String planName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(valueColor1),
        Color(valueColor2),
      ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            planName,
            style: const TextStyle(
              fontFamily: 'KastelovAxiforma',
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            '$price DZD / month',
            style: const TextStyle(
              fontFamily: 'KastelovAxiforma',
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
