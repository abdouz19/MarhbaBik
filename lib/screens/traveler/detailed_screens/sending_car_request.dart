import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marhba_bik/api/e_paiment.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/material_button_auth.dart';
import 'package:marhba_bik/components/white_container_field.dart';
import 'package:marhba_bik/models/car.dart';
import 'package:marhba_bik/screens/traveler/home.dart';

class SendingCarRequestScreen extends StatefulWidget {
  const SendingCarRequestScreen({super.key, required this.car});

  final Car car;

  @override
  State<SendingCarRequestScreen> createState() =>
      _SendingCarRequestScreenState();
}

class _SendingCarRequestScreenState extends State<SendingCarRequestScreen> {
  String? _paymentMethod;
  DateTimeRange? dates;
  double commission = 0; // Change commission type to double
  bool isLoading = false;

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Calculate commission when the screen initializes
    calculateTotalPrice();
  }

  void _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dates = picked;
      });
      // Recalculate total price when dates change
      calculateTotalPrice();
    }
  }

  String getFormattedDateRange() {
    if (dates == null) {
      return 'Cliquez ici pour choisir les dates';
    } else {
      final DateFormat formatter = DateFormat('d MMM');
      final String start = formatter.format(dates!.start);
      final String end = formatter.format(dates!.end);
      final int days = dates!.duration.inDays;
      return '$start au $end ($days jours)';
    }
  }

  int getDays() {
    return dates?.duration.inDays ?? 0;
  }

  Future<void> calculateTotalPrice() async {
    setState(() {
      isLoading = true;
    });

    double pricePerDay = double.parse(widget.car.price);
    int days = getDays();
    double totalPrice = pricePerDay * days;

    try {
      final commissionData = await apiService.calculateCommission(totalPrice);
      print('-------------------------$commissionData');
      setState(() {
        // Parse commission as double
        commission = commissionData['commission'].toDouble();
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        commission = 0;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void presentDialog(bool requestSent, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(requestSent ? 'Demande envoyée' : 'Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (requestSent) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TravelerHomeScreen(),
                    ),
                  );
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
          'Aucun moyen de paiement sélectionné.'); // Payment method not selected
      return;
    }
    if (dates == null || dates!.duration.inDays == 0) {
      presentDialog(false,
          'Veuillez sélectionner des dates valides pour votre réservation.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    await calculateTotalPrice();

    String startDate = dates?.start != null
        ? DateFormat('yyyy-MM-dd').format(dates!.start)
        : 'Non sélectionné';
    String endDate = dates?.end != null
        ? DateFormat('yyyy-MM-dd').format(dates!.end)
        : 'Non sélectionné';
    int days = getDays();
    int totalPrice = (int.parse(widget.car.price) * days) + commission.toInt();
    String paymentMethod = _paymentMethod ?? 'Non sélectionné';

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String carID = widget.car.id;
    String travelerID = userId;
    String targetID = widget.car.ownerId;
    String targetType = "cars";

    String bookingID = await FirestoreService().uploadBookingCars(
      carID: carID,
      travelerID: travelerID,
      targetID: targetID,
      targetType: targetType,
      bookingStatus: 'pending',
      price: (int.parse(widget.car.price) * days),
      commission: commission.toInt(),
      totalPrice: totalPrice,
      days: days,
      pickupDate: startDate,
      returnDate: endDate,
      paymentMethod: paymentMethod,
    );

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
        true, 'Votre demande de réservation a été envoyée avec succès.');
  }

  @override
  Widget build(BuildContext context) {
    String price = widget.car.price;
    int days = getDays();
    int totalPrice = (int.parse(price) * days) + commission.toInt();

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
                          imageUrl: widget.car.images[0],
                          fit: BoxFit.cover,
                          width: 130,
                          height: 100,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.car.brand} ${widget.car.model}',
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              widget.car.title,
                              style: const TextStyle(
                                color: Color(0xff001939),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                            Text(
                              widget.car.wilaya,
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
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CustomContainer(
                title: 'Votre location de voiture',
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
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _pickDateRange,
                              child: Text(
                                getFormattedDateRange(),
                                style: const TextStyle(
                                  color: Color(0xff001939),
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'KastelovAxiforma',
                                  fontSize: 13,
                                ),
                              ),
                            )
                          ],
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: _pickDateRange,
                          child: const Text(
                            'Modifier',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xff001939),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'KastelovAxiforma',
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomContainer(
                title: 'Tarif détaillé',
                content: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${price}DZD x $days jours',
                          style: const TextStyle(
                            color: Color(0xff001939),
                            fontWeight: FontWeight.w300,
                            fontFamily: 'KastelovAxiforma',
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${int.parse(price) * days}DZD',
                          style: const TextStyle(
                            color: Color(0xff001939),
                            fontWeight: FontWeight.w300,
                            fontFamily: 'KastelovAxiforma',
                            fontSize: 13,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
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
                                '${commission.toStringAsFixed(2)}DZD', // Display commission as double
                                style: const TextStyle(
                                  color: Color(0xff001939),
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'KastelovAxiforma',
                                  fontSize: 13,
                                ),
                              )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: const Color(0xff001939).withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    const SizedBox(height: 10),
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
                          isLoading ? 'Loading...' : '${totalPrice}DZD',
                          style: const TextStyle(
                            color: Color(0xff001939),
                            fontWeight: FontWeight.w700,
                            fontFamily: 'KastelovAxiforma',
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5)
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              const Text(
                'Votre réservation ne sera confirmée que lorsque l\'hôte aura accepté votre demande (dans un délai de 24 heures).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xff001939),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'KastelovAxiforma',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
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
