import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/launchers/phone_handler.dart';
import 'package:marhba_bik/widgets/info_message.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

class TravelerBookingsScreen extends StatefulWidget {
  const TravelerBookingsScreen({super.key, required this.travelerID});
  final String travelerID;

  @override
  State<TravelerBookingsScreen> createState() => _TravelerBookingsScreenState();
}

class _TravelerBookingsScreenState extends State<TravelerBookingsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>> carBookings =
        await firestoreService.fetchCarBookingsByTravelerID(widget.travelerID);
    List<Map<String, dynamic>> houseBookings = await firestoreService
        .fetchHouseBookingsByTravelerID(widget.travelerID);
    List<Map<String, dynamic>> tripBookings =
        await firestoreService.fetchTripBookingsByTravelerID(widget.travelerID);

    // Combine all bookings into one list
    List<Map<String, dynamic>> allBookings = [
      ...carBookings,
      ...houseBookings,
      ...tripBookings
    ];

    // Sort the bookings based on the 'createdAt' field
    allBookings.sort((a, b) {
      Timestamp timestampA = a['createdAt'];
      Timestamp timestampB = b['createdAt'];
      return timestampB.compareTo(timestampA); // Descending order
    });

    setState(() {
      _bookings = allBookings;
      _loading = false;
    });
  }

  Future<Map<String, dynamic>?> _getTargetData(
      String collection, String id) async {
    FirestoreService firestoreService = FirestoreService();
    switch (collection) {
      case 'cars':
        return await firestoreService.getCarById(id);
      case 'houses':
        return await firestoreService.getHouseById(id);
      case 'trips':
        return await firestoreService.getTripById(id);
      default:
        return null;
    }
  }

  Future<Map<String, dynamic>?> _getTrip(String tripID) async {
    FirestoreService firestoreService = FirestoreService();
    return await firestoreService.getTripById(tripID);
  }

  String _formatDate(String? date) {
    if (date == null) {
      return 'N/A';
    }
    DateTime dateTime = DateTime.parse(date);
    return DateFormat.MMMd().format(dateTime);
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A';
    }
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.MMMd().format(dateTime);
    return formattedDate;
  }

  String _formatPaymentMethod(String paymentMethod) {
    final Map<String, String> paymentMethodTranslations = {
      'hand_to_hand': 'Main à Main',
      'credit_card': 'Carte de Crédit',
    };

    if (paymentMethodTranslations.containsKey(paymentMethod)) {
      return paymentMethodTranslations[paymentMethod]!;
    } else {
      return paymentMethod
          .split('_')
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
    }
  }

  Future<void> _cancelBooking(
      BuildContext context, String bookingID, int index) async {
    FirestoreService firestoreService = FirestoreService();
    await firestoreService.cancelBooking(bookingID);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation annulée'),
        duration: Duration(seconds: 2),
      ),
    );
    // Update UI
    setState(() {});
  }

  Future<void> _deleteBooking(
      BuildContext context, String bookingID, int index) async {
    FirestoreService firestoreService = FirestoreService();
    await firestoreService.deleteBooking(bookingID);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Réservation annulée'),
        duration: Duration(seconds: 2),
      ),
    );
    // Update UI
    setState(() {
      _bookings.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _bookings.isEmpty
                ? _buildNoBookingsWidget()
                : RefreshIndicator(
                    onRefresh: _fetchBookings,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        final targetType = booking['targetType'];
                        return FutureBuilder(
                          future: _getTargetData(
                              booking['targetType'], booking['id']),
                          builder: (context,
                              AsyncSnapshot<Map<String, dynamic>?> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingSkeleton();
                            } else if (snapshot.hasError) {
                              return Text('Erreur: ${snapshot.error}');
                            } else {
                              Map<String, dynamic>? targetData = snapshot.data;

                              String formattedPickupDate =
                                  _formatDate(booking['pickupDate']);
                              String formattedReturnDate =
                                  _formatDate(booking['returnDate']);
                              String formattedPaymentMethod =
                                  _formatPaymentMethod(
                                      booking['paymentMethod']);
                              String formattedStartDate =
                                  formatDate(targetData?['startDate']);
                              String formattedEndDate =
                                  formatDate(targetData?['endDate']);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff001939)
                                          .withOpacity(0.1),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                targetData?['images']?[0] ?? '',
                                            fit: BoxFit.cover,
                                            width: 150,
                                            height: 100,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (targetType == 'cars') ...[
                                                Text(
                                                  '${targetData?['brand'] ?? targetData?['name']} ${targetData?['model'] ?? ''}',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  targetData?['title'] ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                ),
                                                Text(
                                                  targetData?['wilaya'] ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ] else if (targetType ==
                                                  'houses') ...[
                                                Text(
                                                  targetData?['placeType'] ??
                                                      '',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  targetData?['title'] ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                ),
                                                Text(
                                                  targetData?['address'] ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ] else if (targetType ==
                                                  'trips') ...[
                                                Text(
                                                  '$formattedStartDate - $formattedEndDate',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  targetData?['title'] ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                ),
                                                Text(
                                                  targetData?['wilaya'] ?? '',
                                                  style: const TextStyle(
                                                    color: Color(0xff001939),
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      width: double.infinity,
                                      height: 1,
                                      color: const Color(0xff001939)
                                          .withOpacity(0.1),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        const Text(
                                          'État de la réservation : ',
                                          style: TextStyle(
                                            color: Color(0xff001939),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          // Translate the booking status to French
                                          booking['bookingStatus'] == 'accepted'
                                              ? 'accepté'
                                              : booking['bookingStatus'] ==
                                                      'declined'
                                                  ? 'refusé'
                                                  : booking['bookingStatus'] ==
                                                          'canceled'
                                                      ? 'annulé'
                                                      : 'en attente',
                                          style: TextStyle(
                                            color: booking['bookingStatus'] ==
                                                    'accepted'
                                                ? Colors.green
                                                : booking['bookingStatus'] ==
                                                            'declined' ||
                                                        booking['bookingStatus'] ==
                                                            'canceled'
                                                    ? Colors.red
                                                    : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (targetType == 'cars') ...[
                                      Row(
                                        children: [
                                          const Text(
                                            'Date : ',
                                            style: TextStyle(
                                              color: Color(0xff001939),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '$formattedPickupDate au $formattedReturnDate (${booking['days']} jours)',
                                            style: const TextStyle(
                                              color: Color(0xff989898),
                                              fontSize: 15,
                                            ),
                                          )
                                        ],
                                      ),
                                    ] else if (targetType == 'houses') ...[
                                      Row(
                                        children: [
                                          const Text(
                                            'Date : ',
                                            style: TextStyle(
                                              color: Color(0xff001939),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '$formattedPickupDate au $formattedReturnDate (${booking['nights']} nuits)',
                                            style: const TextStyle(
                                              color: Color(0xff989898),
                                              fontSize: 15,
                                            ),
                                          )
                                        ],
                                      ),
                                    ] else if (targetType == 'trips') ...[
                                      Row(
                                        children: [
                                          const Text(
                                            'Personnes : ',
                                            style: TextStyle(
                                              color: Color(0xff001939),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '${booking['people']} person',
                                            style: const TextStyle(
                                              color: Color(0xff989898),
                                              fontSize: 15,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text(
                                          'Montant total : ',
                                          style: TextStyle(
                                            color: Color(0xff001939),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          '${booking['price']}DZD',
                                          style: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Text(
                                          'Moyen de paiement : ',
                                          style: TextStyle(
                                            color: Color(0xff001939),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          formattedPaymentMethod,
                                          style: const TextStyle(
                                            color: Color(0xff989898),
                                            fontSize: 15,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              await _cancelBooking(
                                                context,
                                                booking['bookingID'],
                                                index,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              elevation: 1,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12.0),
                                              child: Text(
                                                'Annuler',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      'KastelovAxiforma',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: booking[
                                                        'bookingStatus'] ==
                                                    'accepted'
                                                ? () async {
                                                    var status =
                                                        await Permission.phone
                                                            .request();
                                                    if (status.isGranted) {
                                                      String targetID =
                                                          booking['targetID'];
                                                      Map<String, dynamic>?
                                                          userData =
                                                          await FirestoreService()
                                                              .getUserDataById(
                                                                  targetID);
                                                      String? phoneNumber =
                                                          userData?[
                                                              'phoneNumber'];

                                                      if (phoneNumber != null &&
                                                          phoneNumber
                                                              .isNotEmpty) {
                                                        try {
                                                          await PhoneHandler
                                                              .makeCall(
                                                                  phoneNumber);
                                                        } catch (e) {
                                                          print('Error: $e');
                                                        }
                                                      } else {
                                                        print(
                                                            'Phone number not available');
                                                      }
                                                    } else {
                                                      await Permission.phone
                                                          .request();
                                                    }
                                                  }
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              elevation: 1,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12.0),
                                              child: Text(
                                                'Appeler',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily:
                                                      'KastelovAxiforma',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildNoBookingsWidget() {
    return const InfoMessageWidget(
        iconData: Icons.hourglass_empty,
        message: "Pas encore de demandes de réservation.");
  }

  Widget _buildLoadingSkeleton() {
    return SizedBox(
      height: 200,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
