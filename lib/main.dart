import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marhba_bik/auth/getstarted.dart';
import 'package:marhba_bik/auth/login.dart';
import 'package:marhba_bik/auth/signup.dart';
import 'package:marhba_bik/loading_screen.dart';
import 'package:marhba_bik/screens/car_owner/car_owner_home.dart';
import 'package:marhba_bik/screens/car_owner/car_owner_info_form.dart';
import 'package:marhba_bik/screens/home_owner/home_owner_home.dart';
import 'package:marhba_bik/screens/home_owner/home_owner_info_form.dart';
import 'package:marhba_bik/screens/shared/subscription.dart';
import 'package:marhba_bik/screens/traveler/home.dart';
import 'package:marhba_bik/screens/traveler/traveler_info_form.dart';
import 'package:marhba_bik/screens/traveling_agency/travelling_agency_home.dart';
import 'package:marhba_bik/screens/traveling_agency/travelling_agency_info_form.dart';
import 'package:permission_handler/permission_handler.dart';

var kColorScheme = ColorScheme.fromSeed(seedColor: const Color(0xff3F75BB));

Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set French locale for message formatting using await
  String locale = await Intl.getCurrentLocale();
  Intl.defaultLocale = locale; // Set the default locale

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  await requestNotificationPermission(); // Request notification permission on startup

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('****************************User is currently signed out!');
      } else {
        print('****************************User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: determineInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomLoadingScreen(); // Show loading indicator while determining initial route
        }
        final initialRoute = snapshot.data ?? '/getstarted';
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            colorScheme: kColorScheme,
          ),
          initialRoute: initialRoute,
          routes: {
            '/getstarted': (context) =>
                const GetStartedScreen(), // Default route
            '/signup': (context) => const SignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/traveler_home': (context) => const TravelerHomeScreen(),
            '/home_owner_home': (context) => const HomeOwnerHomeScreen(),
            '/car_owner_home': (context) => const CarOwnerHomeScreen(),
            '/travelling_agency_home': (context) =>
                const TravelingAgencyHomeScreen(),
            '/traveler_info_form': (context) => const TravelerInfoFormScreen(),
            '/home_owner_info_form': (context) =>
                const HomeOwnerInfoFormScreen(),
            '/car_owner_info_form': (context) => const CarOwnerInfoFormScreen(),
            '/travelling_agency_info_form': (context) =>
                const TravelingAgencyInfoFormScreen(),
            '/subscription_screen': (context) => const SubscriptionScreen(),
          },
        );
      },
    );
  }

  Future<String> determineInitialRoute() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return '/getstarted';
    } else if (!currentUser.emailVerified) {
      return '/getstarted';
    } else {
      return await getUserRole(currentUser.uid);
    }
  }

  Future<String> getUserRole(String uid) async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userRole = userData['role'];
    final personalDataProvided = userData['personalDataProvided'] ?? false;

    if (personalDataProvided) {
      switch (userRole) {
        case 'traveler':
          return '/traveler_home';
        case 'home owner':
          return '/home_owner_home';
        case 'car owner':
          return '/car_owner_home';
        case 'travelling agency':
          return '/travelling_agency_home';
        default:
          return '/getstarted';
      }
    } else {
      switch (userRole) {
        case 'traveler':
          return '/traveler_info_form';
        case 'home owner':
          return '/home_owner_info_form';
        case 'car owner':
          return '/car_owner_info_form';
        case 'travelling agency':
          return '/travelling_agency_info_form';
        default:
          return '/getstarted';
      }
    }
  }
}
