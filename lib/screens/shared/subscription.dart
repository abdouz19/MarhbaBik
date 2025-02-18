import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/widgets/subscription_offer.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String userName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirestoreService firestoreService = FirestoreService();
        Map<String, dynamic>? userData =
            await firestoreService.getUserDataById(user.uid);
        if (userData != null) {
          if (userData['role'] == 'travelling agency' &&
              userData.containsKey('agencyName')) {
            setState(() {
              userName = userData['agencyName'];
              isLoading = false;
            });
          } else if (userData.containsKey('firstName') &&
              userData.containsKey('lastName')) {
            setState(() {
              userName = '${userData['firstName']} ${userData['lastName']}';
              isLoading = false;
            });
          } else {
            setState(() {
              userName = 'User';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            userName = 'User';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          userName = 'User';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userName = 'User';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      'Hello, $userName',
                      style: const TextStyle(
                        fontFamily: 'KastelovAxiforma',
                        fontSize: 15,
                        color: Color(0xffA3A3A3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
              const SizedBox(
                height: 7,
              ),
              const Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 25,
                  color: Color(0xff001939),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SubscriptionOffer(
                imagePath: 'assets/icons/house_icon.png',
                valueColor1: 0xff7FADE9,
                valueColor2: 0xff3F75BB,
                planName: 'Basic',
                price: 1000,
                textColor: 0xff001939,
                texts: ['1 offer published', 'Medium traffic'],
              ),
              const SubscriptionOffer(
                imagePath: 'assets/icons/building.png',
                valueColor1: 0xffD34113,
                valueColor2: 0xffFF5D2B,
                planName: 'Premium',
                price: 2500,
                textColor: 0xff701B00,
                texts: ['Up to 3 offers published', 'High traffic'],
              ),
              const SubscriptionOffer(
                imagePath: 'assets/icons/rocket.png',
                valueColor1: 0xff001024,
                valueColor2: 0xff001939,
                planName: 'Entreprise',
                price: 5000,
                textColor: 0xff3F75BB,
                texts: ['More than 3 offers published', 'Priority traffic'],
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
