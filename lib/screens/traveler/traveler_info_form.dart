import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marhba_bik/components/custom_checkbox.dart';
import 'package:marhba_bik/components/dropdown_form_field.dart';
import 'package:marhba_bik/components/image_picker.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/components/textfield.dart';

class TravelerInfoFormScreen extends StatefulWidget {
  const TravelerInfoFormScreen({super.key});

  @override
  State<TravelerInfoFormScreen> createState() {
    return _TravelerInfoFormScreenState();
  }
}

class _TravelerInfoFormScreenState extends State<TravelerInfoFormScreen> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController wilaya = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  late ImagePickerDialog _imagePickerDialog;
  File? _imageFile;
  String? _selectedWilaya;
  bool _checkboxChecked = false;

  // Placeholder image URL
  final String placeholderImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/marhbabik-pfe.appspot.com/o/ProfilePictures%2Fplaceholder.png?alt=media&token=bdd7ceb3-55fc-49d7-83d9-07362b18813d';

  @override
  void initState() {
    super.initState();
    _imagePickerDialog = ImagePickerDialog(
      onImageSelected: (pickedImage) {
        handleImage(pickedImage);
      },
    );
  }

  Future<void> handleImage(XFile? pickedImage) async {
    if (pickedImage != null) {
      try {
        setState(() {
          _imageFile = File(pickedImage.path);
        });
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: Text('Erreur lors de la sélection de l\'image: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> signUp(
    BuildContext context,
    GlobalKey<FormState> formState,
    TextEditingController firstName,
    TextEditingController lastName,
    String? selectedWilaya,
    TextEditingController phoneNumber,
    File? imageFile,
    bool checkboxChecked,
  ) async {
    // Show circular progress indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (formState.currentState!.validate()) {
      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;

        String downloadURL = placeholderImageUrl;
        if (imageFile != null) {
          Reference storageReference = FirebaseStorage.instance.ref().child(
              'ProfilePictures/${DateTime.now().millisecondsSinceEpoch}.jpg');

          TaskSnapshot uploadTask = await storageReference.putFile(imageFile);

          downloadURL = await uploadTask.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'firstName': firstName.text,
          'lastName': lastName.text,
          'wilaya': selectedWilaya,
          'phoneNumber': phoneNumber.text,
          'profilePicture': downloadURL,
          'personalDataProvided': true,
        });

        Navigator.pushReplacementNamed(context, '/traveler_home');
      } catch (e) {
        // Close the circular progress indicator dialog
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: const Text(
                'Une erreur s\'est produite lors de l\'inscription. Veuillez réessayer plus tard.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Form validation failed, show snack bar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
          duration: Duration(seconds: 2),
        ),
      );
      // Close the circular progress indicator dialog
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    wilaya.dispose();
    phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Form(
              key: formState,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      'Pour continuer en tant que voyageur, veuillez remplir ces informations',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff3F75BB),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return _imagePickerDialog;
                                },
                              );
                            },
                            child: Container(
                              width: 200,
                              height: 100,
                              alignment: Alignment.center,
                              child: _imageFile != null
                                  ? ClipOval(
                                      child: Image.file(
                                        _imageFile!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/picture.jpg',
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                          ),
                          if (_imageFile != null)
                            Positioned(
                              left: 10,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    // Add logic to delete the picked image
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  iconSize: 30,
                                ),
                              ),
                            ),
                          if (_imageFile != null)
                            Positioned(
                              right: 10,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                child: IconButton(
                                  onPressed: () async {
                                    // Reset the _imageFile to null
                                    setState(() {
                                      _imageFile = null;
                                    });
                                    await Future.delayed(
                                        const Duration(milliseconds: 100));
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return _imagePickerDialog;
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  iconSize: 30,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CustomizedTextFormField(
                      label: 'Prénom',
                      hintText: 'Ex: Prénom',
                      textEditingController: firstName,
                      validator: (v) {
                        if (v == "") {
                          return "Oups ! Ce champ ne peut pas être vide.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomizedTextFormField(
                      label: 'Nom',
                      hintText: 'Ex: Nom',
                      textEditingController: lastName,
                      validator: (v) {
                        if (v == "") {
                          return "Oups ! Ce champ ne peut pas être vide.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    WilayaDropdown(
                      controller: wilaya,
                      hintText: 'Sélectionner une région',
                      labelText: 'Wilaya',
                      validator: (v) {
                        if (v == "") {
                          return "Oups ! Ce champ ne peut pas être vide.";
                        }
                        return null;
                      },
                      onWilayaSelected: (wilaya) {
                        // Pass the callback function
                        setState(() {
                          _selectedWilaya = wilaya;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomizedTextFormField(
                      label: 'Numéro de téléphone',
                      hintText: 'Ex: Numéro de téléphone',
                      textEditingController: phoneNumber,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == "") {
                          return "Oups ! Ce champ ne peut pas être vide.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomCheckbox(
                      isChecked: _checkboxChecked,
                      onChanged: (value) {
                        setState(() {
                          _checkboxChecked = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    MaterialButtonAuth(
                      onPressed: () {
                        if (_selectedWilaya == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Veuillez sélectionner une wilaya.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else if (!_checkboxChecked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez cocher la case.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          signUp(
                            context,
                            formState,
                            firstName,
                            lastName,
                            _selectedWilaya,
                            phoneNumber,
                            _imageFile,
                            _checkboxChecked,
                          );
                        }
                      },
                      label: 'Terminer mon inscription',
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
