import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:marhba_bik/screens/car_owner/uploading_car_phases/uploading_car_process.dart';
import 'package:marhba_bik/widgets/custom_carousel.dart';
import 'package:marhba_bik/widgets/info_message.dart';

class CarOwnerOffers extends StatefulWidget {
  const CarOwnerOffers({super.key});

  @override
  State<CarOwnerOffers> createState() => _CarOwnerOffersState();
}

class _CarOwnerOffersState extends State<CarOwnerOffers> {
  Future<List<Map<String, dynamic>>>? _futureCars;

  @override
  void initState() {
    super.initState();
    _futureCars = fetchUserCars();
  }

  void showScreen() {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return const UploadingCarProcess();
        });
  }

  Future<List<Map<String, dynamic>>> fetchUserCars() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('cars')
        .where('ownerId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _futureCars = fetchUserCars();
    });
    await _futureCars;
  }

  Future<void> _deleteOffer(String offerId) async {
    await FirebaseFirestore.instance.collection('cars').doc(offerId).delete();
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vos voitures',
          style: GoogleFonts.poppins(
            color: const Color(0xff001939),
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showScreen();
            },
            icon: const Icon(
              Icons.add_rounded,
              size: 35,
            ),
          )
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        showChildOpacityTransition: false,
        color: const Color(0xff3F75BB),
        animSpeedFactor: 2,
        springAnimationDurationInMilliseconds: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureCars,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const InfoMessageWidget(
                    iconData: Icons.error,
                    message:
                        "Une erreur s'est produite lors de la récupération de vos offres.");
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return  InfoMessageWidget(
                      iconData: Icons.hourglass_empty,
                      onTap: showScreen,
                      message:
                          "Vous n'avez pas encore publié d'offres. Cliquez ici pour ajouter vos offres.");
              } else {
                List<Map<String, dynamic>> cars = snapshot.data!;
                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> car = cars[index];
                    List<String> imageUrls = List<String>.from(car['images']);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCarouselSlider(
                          imageUrls: imageUrls,
                          height: 300.0,
                          offer: car,
                          onDelete: () => _deleteOffer(car['id']),
                          offerType: 'car',
                        ),
                        const SizedBox(height: 15),
                        Text(
                          car['title'] ?? '',
                          style: GoogleFonts.poppins(
                            color: const Color(0xff001939),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          '${car['brand']} ${car['model']}, ${car['wilaya']}',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            color: const Color(0xff666666),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          '${car['price']} DZD/jour',
                          style: GoogleFonts.poppins(
                            color: const Color(0xff001939),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
