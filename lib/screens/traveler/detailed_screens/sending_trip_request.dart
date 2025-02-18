import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marhba_bik/api/e_paiment.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/capacity_selector.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/components/white_container_field.dart';
import 'package:marhba_bik/models/trip.dart';
import 'package:marhba_bik/screens/traveler/home.dart';

class SendingTripRequestScreen extends StatefulWidget {
  const SendingTripRequestScreen({super.key, required this.trip});

  final Trip trip;

  @override
  State<SendingTripRequestScreen> createState() =>
      _SendingTripRequestScreenState();
}

class _SendingTripRequestScreenState extends State<SendingTripRequestScreen> {
  String? _paymentMethod;
  int selectedCapacity = 1;
  double commission = 0;
  bool isLoading = false;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    calculateTotalPrice();
  }

  void _updateTotalPrice() {
    setState(() {
      calculateTotalPrice();
    });
  }

  int getPeople() {
    return selectedCapacity;
  }

  Future<double> calculateTotalPrice() async {
    setState(() {
      isLoading = true;
    });

    double pricePerPerson = double.parse(widget.trip.price);
    int people = getPeople();
    double totalPrice = (pricePerPerson * people).toDouble();
    try {
      final commissionData =
          await apiService.calculateCommission(totalPrice.toDouble());
      setState(() {
        commission = commissionData['commission'].toDouble();
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        commission = 0.0;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    return totalPrice + commission;
  }

  void presentDialog(bool requestSent, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(requestSent ? 'Demande envoyée ' : 'Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (requestSent) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TravelerHomeScreen()));
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _requestToBook() async {
    if (_paymentMethod == null) {
      presentDialog(false,
          'Veuillez choisir un moyen de paiement avant d\'envoyer la demande.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    int people = getPeople();
    String paymentMethod = _paymentMethod ?? 'Non sélectionné';
    int pricePerPerson = int.parse(widget.trip.price);
    double totalPrice = (pricePerPerson * people) + commission;

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String travelerID = userId;
    String targetID = widget.trip.agencyId;
    String targetType = "trips";
    String tripID = widget.trip.id;
    Timestamp startDate = widget.trip.startDate;
    Timestamp endDate = widget.trip.endDate;

    String bookingID = await FirestoreService().uploadBookingTrips(
        tripId: tripID,
        travelerID: travelerID,
        targetID: targetID,
        targetType: targetType,
        bookingStatus: 'pending',
        price: pricePerPerson * people,
        commission: commission.toInt(),
        totalPrice: totalPrice.toInt(),
        people: people,
        paymentMethod: paymentMethod,
        endDate: endDate,
        startDate: startDate);

    if (bookingID.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingID)
          .update({
        'bookingID': bookingID,
      });
      print("Booking ID updated successfully: $bookingID");
    }

    setState(() {
      isLoading = false;
    });

    presentDialog(
        true, ' Votre demande de réservation a été envoyée avec succès.');
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = widget.trip.startDate.toDate();
    DateTime endDate = widget.trip.endDate.toDate();

    // Format the dates
    String formattedStartDate = DateFormat('d MMM').format(startDate);
    String formattedEndDate = DateFormat('d MMM').format(endDate);

    // Combined date range string
    String dateRange = '$formattedStartDate - $formattedEndDate';
    int people = getPeople();
    double totalPrice = (int.parse(widget.trip.price) * people) + commission;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          centerTitle: true,
          title: const Text(
            'Demander à réserver',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xff001939),
              fontWeight: FontWeight.w700,
              fontFamily: 'KastelovAxiforma',
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomContainer(
                content: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: CachedNetworkImage(
                          imageUrl: widget.trip.images[0],
                          fit: BoxFit.cover,
                          width: 130,
                          height: 100,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateRange,
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              widget.trip.title,
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            Text(
                              widget.trip.wilaya,
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomContainer(
                title: 'Votre voyage',
                content: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dates',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w700,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              dateRange,
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w300,
                                fontFamily: 'KastelovAxiforma',
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'personnes',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff001939),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'KastelovAxiforma',
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CapacitySelector(
                          space: 13,
                          paddingNumber: 1,
                          initialCapacity: 1,
                          onCapacityChanged: (v) {
                            setState(() {
                              selectedCapacity = v;
                              _updateTotalPrice();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomContainer(
                title: 'Tarifs Détaillés',
                content: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.trip.price}DZD x $people person',
                          style: const TextStyle(
                            color: Color(0xff001939),
                            fontWeight: FontWeight.w300,
                            fontFamily: 'KastelovAxiforma',
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(int.parse(widget.trip.price) * people)}DZD',
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
                          'Commission',
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
                                '${commission.toInt()}DZD',
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
                          'Total',
                          style: TextStyle(
                            color: Color(0xff001939),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'KastelovAxiforma',
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          isLoading ? 'Loading...' : '${totalPrice.toInt()}DZD',
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
              const SizedBox(
                height: 20,
              ),
              CustomContainer(
                title: 'Payer par',
                content: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.credit_card),
                      title: const Text(
                        'Carte de crédit',
                        style: TextStyle(
                          color: Color(0xff001939),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'KastelovAxiforma',
                          fontSize: 14,
                        ),
                      ),
                      trailing: Radio<String>(
                        value: 'credit_card',
                        groupValue: _paymentMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _paymentMethod = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _paymentMethod = 'credit_card';
                        });
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.money_rounded),
                      title: const Text(
                        'En espèces',
                        style: TextStyle(
                          color: Color(0xff001939),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'KastelovAxiforma',
                          fontSize: 14,
                        ),
                      ),
                      trailing: Radio<String>(
                        value: 'hand_to_hand',
                        groupValue: _paymentMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _paymentMethod = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _paymentMethod = 'hand_to_hand';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Votre réservation ne sera confirmée que lorsque l\'hôte aura accepté votre demande (sous 24 heures).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff001939),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 13,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MaterialButtonAuth(
                onPressed: _requestToBook,
                label: 'Demander à réserver',
              )
            ],
          ),
        ),
      ),
    );
  }
}
