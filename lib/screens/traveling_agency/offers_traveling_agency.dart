import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marhba_bik/widgets/custom_carousel.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:marhba_bik/screens/traveling_agency/uploading_trip_phases/uploading_trip_process.dart';
import 'package:marhba_bik/widgets/info_message.dart';

class TravelingAgencyOffers extends StatefulWidget {
  const TravelingAgencyOffers({super.key});

  @override
  State<TravelingAgencyOffers> createState() => _TravelingAgencyOffersState();
}

class _TravelingAgencyOffersState extends State<TravelingAgencyOffers> {

  Future<List<Map<String, dynamic>>>? _futureTrips;

  @override
  void initState() {
    super.initState();
    _futureTrips = fetchUserTrips();
  }

  void showScreen() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return const UploadingTripProcess();
      });
  }

  Future<List<Map<String, dynamic>>> fetchUserTrips() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('agencyId', isEqualTo: userId)
        .orderBy('uploadedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _futureTrips = fetchUserTrips();
    });
    await _futureTrips;
  }

  Future<void> _deleteOffer(String offerId) async {
    await FirebaseFirestore.instance.collection('trips').doc(offerId).delete();
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vos voyages',
          style: GoogleFonts.poppins(
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
            future: _futureTrips,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const InfoMessageWidget(
                    iconData: Icons.error,
                    message:
                        "Une erreur s'est produite lors de la récupération de vos offres.");
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return InfoMessageWidget(
                      iconData: Icons.hourglass_empty,
                      onTap: showScreen,
                      message:
                          "Vous n'avez pas encore publié d'offres. Cliquez ici pour ajouter vos offres.");
              
              } else {
                List<Map<String, dynamic>> trips = snapshot.data!;
                return ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> trip = trips[index];
                    List<String> activities = List<String>.from(trip['activities']);
                    String formattedActivities = activities.map((activity) => activity.trim()).join(', ');
                    List<String> imageUrls = List<String>.from(trip['images']);
                    DateTime startDate = (trip['startDate'] as Timestamp).toDate();
                    DateTime endDate = (trip['endDate'] as Timestamp).toDate();
                    DateTime now = DateTime.now();
                    String dateStatus;

                    if (now.isBefore(startDate)) {
                      dateStatus = "À venir";
                    } else if (now.isAfter(endDate)) {
                      dateStatus = "Expiré";
                    } else {
                      dateStatus = "En cours";
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCarouselSlider(
                          imageUrls: imageUrls,
                          height: 300.0,
                          offer: trip,
                          onDelete: () => _deleteOffer(trip['id']),
                          offerType: 'trip',
                        ),
                        const SizedBox(height: 15),
                        Text(
                          trip['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3,),
                        Text(
                          '$formattedActivities à ${trip['wilaya']}',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            color: const Color(0xff666666),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 3,),
                        Text(
                          '${trip['price']} DZD/person',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3,),
                        Text(
                          dateStatus,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: dateStatus == "À venir"
                                ? Colors.green
                                : dateStatus == "Expiré"
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 30,),
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
