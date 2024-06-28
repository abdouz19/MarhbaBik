import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marhba_bik/api/e_paiment.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/components/white_container_field.dart';
import 'package:marhba_bik/launchers/webview.dart';
import 'package:marhba_bik/screens/car_owner/car_owner_home.dart';
import 'package:marhba_bik/screens/home_owner/home_owner_home.dart';
import 'package:marhba_bik/screens/shared/subscription_card.dart';
import 'package:marhba_bik/screens/shared/subscription_header.dart';
import 'package:marhba_bik/screens/traveling_agency/travelling_agency_home.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen(
      {super.key,
      required this.imagePath,
      required this.valueColor1,
      required this.planName,
      required this.price,
      required this.texts,
      required this.textColor,
      required this.valueColor2});

  final String imagePath;
  final int valueColor1;
  final int valueColor2;
  final String planName;
  final double price;
  final List<String> texts;
  final int textColor;

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  double commission = 0;
  bool isLoading = false;
  double totalPrice = 0;
  bool isCheckingTransfer = false;

  ApiService apiService = ApiService();

  Future<void> calculateTotalPrice() async {
    setState(() {
      isLoading = true;
    });
    print('--------$commission');
    try {
      final commissionData = await apiService.calculateCommission(widget.price);
      print('--------$commission');
      if (mounted) {
        setState(() {
          commission = (commissionData['commission'] as num).toDouble();
          print('--------$commission');
          totalPrice = widget.price + commission;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() {
          commission = 0;
          totalPrice = widget.price as double;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> handleProceed() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      isLoading = true;
      isCheckingTransfer = true; // Start checking transfer
    });
    try {
      final result = await apiService.createTransfer(widget.price, uid);
      print(result);

      if (result['success']) {
        final String url = result['url'];
        final String transferId = result['id'].toString();

        // Navigate to WebViewScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(url: url),
          ),
        );

        // Declare transferDetails outside the loop
        Map<String, dynamic>? transferDetails;

        // Continuously check transfer details until completed
        bool completed = false;
        while (!completed && isCheckingTransfer) {
          // Check if still allowed to run
          transferDetails = await apiService.getTransferDetails(transferId);
          print(
              '------------------------------------------------------Transfer details: $transferDetails');

          // Check if transfer is completed
          completed = transferDetails['completed'];

          if (!completed) {
            // Wait for 3 seconds before checking again
            await Future.delayed(const Duration(seconds: 3));
          }
        }

        if (completed && transferDetails != null) {
          // Parse created_at and calculate expiration date
          final createdAt =
              DateTime.parse(transferDetails['data']['created_at']);
          final expirationDate = createdAt.add(const Duration(days: 30));

          // Save subscription to Firestore
          final subscriptionData = {
            'userId': uid,
            'transferId': transferDetails['data']['id'],
            'serial': transferDetails['data']['serial'],
            'amount': transferDetails['data']['amount'],
            'rib': transferDetails['data']['rib'],
            'firstname': transferDetails['data']['firstname'],
            'lastname': transferDetails['data']['lastname'],
            'address': transferDetails['data']['address'],
            'status': transferDetails['data']['status'],
            'created_at': transferDetails['data']['created_at'],
            'expiration_date': DateFormat('yyyy-MM-dd').format(expirationDate),
          };

          await FirestoreService().saveSubscription(uid, subscriptionData);

          // Handle completed transfer
          print(
              '------------------------------------------------------Transfer completed successfully and subscription saved.');

          // Navigate to OffersCarOwnerScreen
          if (mounted) {
            String? userRole = await FirestoreService()
                .getUserRole(FirebaseAuth.instance.currentUser!.uid);
            if (userRole != null) {
              switch (userRole) {
                case 'car owner':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarOwnerHomeScreen(),
                    ),
                  );
                  break;
                case 'home owner':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeOwnerHomeScreen(),
                    ),
                  );
                  break;
                case 'travelling agency':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TravelingAgencyHomeScreen(),
                    ),
                  );
                  break;
                default:
                  break;
              }
            } else {}
          }
        } else {
          // Handle incomplete transfer
          if (!completed) {
            print(
                '-------------------------------------------------------Transfer not completed.');
          }
        }
      } else {
        throw Exception(
            '----------------------------------------------------------${result['message']}');
      }
    } catch (e) {
      // Error handling
      print(
          '-------------------------------------------------------------------Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isCheckingTransfer = false; // Stop checking transfer
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
  }

  @override
  void dispose() {
    isCheckingTransfer =
        false; // Stop checking transfer when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SubscriptionHeader(
                  planName: widget.planName,
                  price: widget.price,
                  valueColor1: widget.valueColor1,
                  valueColor2: widget.valueColor2,
                ),
                const SizedBox(
                  height: 40,
                ),
                SubscriptionCard(
                  imagePath: widget.imagePath,
                  textColor: widget.textColor,
                  texts: widget.texts,
                  valueColor1: widget.valueColor1,
                  valueColor2: widget.valueColor2,
                  planName: widget.planName,
                  price: widget.price,
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: CustomContainer(
                    title: 'Subscription details',
                    content: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Plan price',
                              style: TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w300,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${widget.price} DZD',
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w300,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Commission fee',
                              style: TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w300,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            isLoading
                                ? const CircularProgressIndicator()
                                : Text(
                                    '$commission DZD',
                                    style: const TextStyle(
                                      color: Color(0xff001939),
                                      fontWeight: FontWeight.w300,
                                      fontFamily: 'KastelovAxiforma',
                                      fontSize: 13,
                                    ),
                                  )
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: const Color(0xff001939).withOpacity(0.1),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Total amount',
                              style: TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              isLoading ? 'Loading...' : '$totalPrice DZD',
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: MaterialButtonAuth(
                        onPressed: handleProceed, label: 'Proceed'))
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              onPressed: () {
                setState(() {
                  isCheckingTransfer =
                      false; // Stop checking transfer on back navigation
                });
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
