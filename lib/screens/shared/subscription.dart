import 'package:flutter/material.dart';
import 'package:marhba_bik/widgets/subscription_offer.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Hello, Abderraouf ZOUAID',
                style: TextStyle(
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 15,
                  color: Color(0xffA3A3A3),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 25,
                  color: Color(0xff001939),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SubscriptionOffer(
                imagePath: 'assets/icons/house_icon.png',
                valueColor1: 0xff7FADE9,
                valueColor2: 0xff3F75BB,
                planName: 'Basic',
                price: 1000,
                textColor: 0xff001939,
                texts: ['lorem ipsum lorem ipsum', 'lorem ipsum lorem ipsum'],
              ),
              SubscriptionOffer(
                imagePath: 'assets/icons/building.png',
                valueColor1: 0xffD34113,
                valueColor2: 0xffFF5D2B,
                planName: 'Premium',
                price: 2500,
                textColor: 0xff701B00,
                texts: ['lorem ipsum lorem ipsum', 'lorem ipsum lorem ipsum'],
              ),
              SubscriptionOffer(
                imagePath: 'assets/icons/rocket.png',
                valueColor1: 0xff001024,
                valueColor2: 0xff001939,
                planName: 'Entreprise',
                price: 5000,
                textColor: 0xff3F75BB,
                texts: ['lorem ipsum lorem ipsum', 'lorem ipsum lorem ipsum'],
              ),
              SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
