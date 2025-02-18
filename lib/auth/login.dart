import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/api/user_services.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/components/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void onPushScreen(String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  void presentDialog(String title, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xff3F75BB),
          ),
          Positioned.fill(
            top: 150,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formState,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'MarhbaBik!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xff001939),
                          fontFamily: 'KastelovAxiforma',
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),
                      CustomizedTextFormField(
                        label: 'Email',
                        hintText: 'Ex: exemple@email.com',
                        icon: Icons.email,
                        textEditingController: emailController,
                        validator: (v) {
                          if (v == "") {
                            return "Oups ! Ce champ ne peut pas être vide.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomizedTextFormField(
                        label: 'Mot de passe',
                        hintText: '**********',
                        icon: Icons.lock,
                        textEditingController: passwordController,
                        isPassword: true,
                        validator: (v) {
                          if (v == "") {
                            return "Oups ! Ce champ ne peut pas être vide.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () async {
                          if (emailController.text == "") {
                            presentDialog(
                                "Oops ! On dirait que vous avez oublié quelque chose...",
                                "Veuillez entrer votre adresse e-mail avant de continuer pour réinitialiser votre mot de passe.");
                            return;
                          }
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                                email: emailController.text);
                            presentDialog(
                                'Email de réinitialisation de mot de passe envoyé !',
                                'Nous vous avons envoyé un e-mail avec un lien pour réinitialiser votre mot de passe. Veuillez vérifier votre boîte de réception et suivre les instructions fournies.');
                          } catch (e) {
                            presentDialog('E-mail invalide',
                                'Veuillez vous assurer que l\'adresse e-mail saisie est correcte et réessayer.');
                          }
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.poppins(
                            color: const Color(0xff3F75BB),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      MaterialButtonAuth(
                        label: 'Connexion',
                        onPressed: () async {
                          // Show circular progress indicator
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // Prevent dismissing the dialog by tapping outside
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          if (formState.currentState!.validate()) {
                            try {
                              final credential = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              if (credential.user!.emailVerified) {
                                // Get user data from Firestore
                                final userData = await firestore
                                    .collection('users')
                                    .doc(credential.user!.uid)
                                    .get();
                                final userRole = userData['role'];
                                final personalDataProvided =
                                    userData['personalDataProvided'] ?? false;

                                await _userService.storeUserToken();

                                if (userRole == 'traveler') {
                                  // For travelers, skip subscription check and navigate based on personal data
                                  if (personalDataProvided) {
                                    onPushScreen('/traveler_home');
                                  } else {
                                    onPushScreen('/traveler_info_form');
                                  }
                                } else {
                                  // For other users, check if personal data is provided
                                  if (personalDataProvided) {
                                    // Check if subscription is paid
                                    final isSubscriptionPaid =
                                        await FirestoreService()
                                            .checkSubscriptionPayment(
                                                credential.user!.uid);

                                    // Navigate based on user role and subscription payment
                                    if (isSubscriptionPaid) {
                                      switch (userRole) {
                                        case 'home owner':
                                          onPushScreen('/home_owner_home');
                                          break;
                                        case 'car owner':
                                          onPushScreen('/car_owner_home');
                                          break;
                                        case 'travelling agency':
                                          onPushScreen(
                                              '/travelling_agency_home');
                                          break;
                                        default:
                                          presentDialog('Unknown User Role',
                                              'User role not recognized.');
                                      }
                                    } else {
                                      // Redirect to SubscriptionScreen
                                      onPushScreen('/subscription_screen');
                                    }
                                  } else {
                                    // Redirect to info form based on user role
                                    switch (userRole) {
                                      case 'home owner':
                                        onPushScreen('/home_owner_info_form');
                                        break;
                                      case 'car owner':
                                        onPushScreen('/car_owner_info_form');
                                        break;
                                      case 'travelling agency':
                                        onPushScreen(
                                            '/travelling_agency_info_form');
                                        break;
                                      default:
                                        presentDialog('Unknown User Role',
                                            'User role not recognized.');
                                    }
                                  }
                                }
                              } else {
                                presentDialog(
                                  'Vérification du compte requise',
                                  'Veuillez vérifier votre e-mail et cliquer sur le lien fourni pour vérifier votre compte. Une fois vérifié, votre compte sera activé.',
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              String errorMessage = '';
                              if (e.code == 'user-not-found') {
                                errorMessage =
                                    'Désolé, nous n\'avons pas trouvé de compte associé à cette adresse e-mail';
                              } else if (e.code == 'wrong-password') {
                                errorMessage =
                                    'Le mot de passe que vous avez saisi est incorrect. Veuillez réessayer.';
                              } else {
                                errorMessage =
                                    'Une erreur s\'est produite: ${e.message}';
                              }
                              // Close the circular progress indicator dialog
                              Navigator.pop(context);
                              presentDialog(
                                  'Erreur d\'authentification', errorMessage);
                            }
                          } else {
                            // Close the circular progress indicator dialog
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          onPushScreen('/signup');
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Vous n'avez pas de compte ?",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xff888888),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ),
                              ),
                              TextSpan(
                                text: " Inscrire",
                                style: GoogleFonts.poppins(
                                  color: const Color(0xff3F75BB),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
