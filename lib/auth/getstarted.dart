import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:marhba_bik/api/user_services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GetStartedScreenState();
  }
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final UserService _userService = UserService();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'email': user.email,
            'role': 'traveler',
            'personalDataProvided': true,
            'firstName': user.displayName?.split(' ').first ?? '',
            'lastName': user.displayName?.split(' ').last ?? '',
            'phoneNumber': user.phoneNumber ?? '',
            'profilePicture': user.photoURL ?? '',
            'wilaya': 'Algiers',
          });
        }

        await _userService.storeUserToken();
        Navigator.of(context).pushReplacementNamed('/traveler_home');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Widget buildButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
    required Color buttonColor,
    bool isOutlined = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
      width: double.infinity,
      child: SizedBox(
        height: 48,
        child: isOutlined
            ? OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  side: BorderSide(color: iconColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              )
            : MaterialButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                onPressed: onPressed,
                color: buttonColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Icon(
                      icon,
                      color: iconColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void onPushScreen(String route) {
      Navigator.of(context).pushNamed(route);
    }

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      color: const Color(0xff3F75BB),
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(84),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Image(
                              image: AssetImage(
                                  'assets/images/marhbabik_new_icon.png')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff3F75BB),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(84),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'MarhbaBik!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'KastelovAxiforma',
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Partez à la découverte de l'Algérie avec MarhbaBik",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'KastelovAxiforma',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 30),
                      buildButton(
                        onPressed: () {
                          signInWithGoogle(context);
                        },
                        icon: MdiIcons.google,
                        iconColor: const Color(0xff3F75BB),
                        text: 'Continuer avec Google',
                        textColor: const Color(0xff3F75BB),
                        buttonColor: Colors.white,
                      ),
                      buildButton(
                        onPressed: () {
                          onPushScreen('/login');
                        },
                        icon: Icons.email,
                        iconColor: Colors.white,
                        text: 'Continuer avec E-mail',
                        textColor: Colors.white,
                        buttonColor: Colors.transparent,
                        isOutlined: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
