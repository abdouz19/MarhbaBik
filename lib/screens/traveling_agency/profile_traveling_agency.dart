import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:marhba_bik/components/outlined_material_button.dart';
import 'package:marhba_bik/screens/traveling_agency/edit_profile_trevling_agency.dart';
import 'package:marhba_bik/screens/traveling_agency/trips_requests.dart';

class TravelingAgencyProfile extends StatefulWidget {
  const TravelingAgencyProfile({super.key});

  @override
  State<TravelingAgencyProfile> createState() => _TravelingAgencyProfileState();
}

class _TravelingAgencyProfileState extends State<TravelingAgencyProfile> {
  String _agencyName = '';
  String _profilePicture = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        setState(() {
          _agencyName = userSnapshot['agencyName'];
          _profilePicture = userSnapshot['profilePicture'];
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: _profilePicture.isNotEmpty
                                ? CachedNetworkImage(
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    imageUrl: _profilePicture,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/placeholder.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _agencyName.length > 10
                                    ? _agencyName.substring(0, 10)
                                    : _agencyName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_agencyName.length > 10)
                                Text(
                                  _agencyName.substring(10),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 150, // Adjust height as needed
                        color: Colors.black
                            .withOpacity(0.1), // Color of the divider
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "42",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Bookings",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 1,
                            color: Colors.black.withOpacity(0.1),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                          ),
                          Text(
                            "4.2/5 rating",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Reviews",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                "Paramètres",
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomizedOutlinedMaterialButton(
                icon: Icons.person_rounded,
                color: const Color(0xff3F75BB),
                label: 'Données personnelles',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: ((contaxt) =>
                          const TravelingAgencyEditProfile())));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CustomizedOutlinedMaterialButton(
                icon: Icons.travel_explore_rounded,
                color: const Color(0xff3F75BB),
                label: 'Vos demandes',
                onPressed: () {
                  String userId = FirebaseAuth.instance.currentUser!.uid;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripsOffersScreen(
                          userID: userId,
                        ),
                      ));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CustomizedOutlinedMaterialButton(
                icon: Icons.security_rounded,
                label: 'À propos',
                color: const Color(0xff3F75BB),
                onPressed: () {},
              ),
              const SizedBox(
                height: 10,
              ),
              CustomizedOutlinedMaterialButton(
                icon: Icons.exit_to_app,
                label: 'Se déconnecter',
                color: const Color(0xffFF0000),
                onPressed: () async {
                  GoogleSignIn googleSignIn = GoogleSignIn();
                  googleSignIn.disconnect();
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/getstarted', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
