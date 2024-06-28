import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/components/textfield.dart';
import 'package:marhba_bik/data/constant_data.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() {
    return _SignupScreen();
  }
}

class _SignupScreen extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UserTypes _selectedUserType = UserTypes.traveler;
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String formatUserType(UserTypes userType) {
    String userTypeString = userType.toString().split('.').last;
    return userTypeString
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}')
        .toLowerCase();
  }

  void onPushScreen(String route) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  void presentDialog(
      String title, String errorMessage, void Function()? onPressed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Rejoignez MarhbaBik',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff001939),
                        fontFamily: 'KastelovAxiforma',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: formState,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Vous êtes ',
                              textAlign: TextAlign.start,
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Color(0xff6F6F6F),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          DropdownButtonFormField<UserTypes>(
                            validator: (v) {
                              if (v == null) {
                                return "Oups ! Ce champ ne peut pas être vide.";
                              }
                              return null;
                            },
                            value: _selectedUserType,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedUserType = newValue!;
                              });
                            },
                            items: UserTypes.values
                                .map<DropdownMenuItem<UserTypes>>(
                                    (UserTypes userType) {
                              return DropdownMenuItem<UserTypes>(
                                value: userType,
                                child: Text(
                                    'Je suis un ${formatUserType(userType)}'),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFAFAFA),
                              hintText: 'Sélectionnez le type d\'utilisateur',
                              hintStyle: const TextStyle(
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w400,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.only(left: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    CustomizedTextFormField(
                      label: 'Email',
                      hintText: 'ex: exemple@email.com',
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
                    const SizedBox(height: 25),
                    MaterialButtonAuth(
                      label: 'Inscription',
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
                                .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            // Add user data to Firestore
                            final userUid = credential.user!.uid;
                            await firestore
                                .collection('users')
                                .doc(userUid)
                                .set({
                              'uid': userUid,
                              'email': emailController.text,
                              'role': formatUserType(_selectedUserType),
                              'personalDataProvided': false,
                            });
                            // send Email Verification
                            await FirebaseAuth.instance.currentUser!
                                .sendEmailVerification();
                            // Close the circular progress indicator dialog
                            Navigator.pop(context);
                            presentDialog(
                                'Compte créé avec succès !',
                                'Veuillez vérifier votre e-mail pour valider votre compte. Une fois validé, vous pourrez vous connecter.',
                                () => onPushScreen('/login'));
                          } on FirebaseAuthException catch (e) {
                            String errorMessage = '';
                            if (e.code == 'weak-password') {
                              errorMessage =
                                  'Le mot de passe fourni est trop faible.';
                            } else if (e.code == 'email-already-in-use') {
                              errorMessage =
                                  'Un compte existe déjà pour cette adresse e-mail.';
                            } else {
                              errorMessage =
                                  'Une erreur s\'est produite: ${e.message}';
                            }
                            // Close the circular progress indicator dialog
                            Navigator.pop(context);
                            presentDialog('Erreur d\'inscription', errorMessage,
                                () => Navigator.pop(context));
                          } catch (e) {
                            // Close the circular progress indicator dialog
                            Navigator.pop(context);
                            presentDialog(
                                'Oups ! Quelque chose s\'est mal passé',
                                'Une erreur inattendue s\'est produite : $e. Veuillez réessayer plus tard ou contacter le support pour obtenir de l\'aide.',
                                () => Navigator.pop(context));
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        onPushScreen('/login');
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Vous avez déjà un compte ?",
                              style: GoogleFonts.poppins(
                                color: const Color(0xff888888),
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: " Connecter",
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
        ],
      ),
    );
  }
}
