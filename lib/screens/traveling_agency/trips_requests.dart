import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/widgets/info_message.dart';
import 'package:shimmer/shimmer.dart';

class TripsOffersScreen extends StatefulWidget {
  const TripsOffersScreen({super.key, required this.userID});
  final String userID;

  @override
  State<TripsOffersScreen> createState() => _TripsOffersScreenState();
}

class _TripsOffersScreenState extends State<TripsOffersScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tripBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchTripBookings();
  }

  Future<void> _fetchTripBookings() async {
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>> bookings =
        await firestoreService.fetchBookingTrips(widget.userID);
    setState(() {
      _tripBookings = bookings;
      _loading = false;
    });
  }

  Future<Map<String, dynamic>?> _getUserData(String userID) async {
    FirestoreService firestoreService = FirestoreService();
    return await firestoreService.getUserDataById(userID);
  }

  Future<Map<String, dynamic>?> _getTrip(String tripID) async {
    FirestoreService firestoreService = FirestoreService();
    return await firestoreService.getTripById(tripID);
  }

  String _formatDate(Timestamp? timestamp) {
    print('-----------------$timestamp');
    if (timestamp == null) {
      return 'N/A';
    }
    DateTime dateTime = timestamp.toDate();

    // Format the dates
    String formattedDate = DateFormat('d MMM').format(dateTime);

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

  Future<void> _updateBookingStatus(
      BuildContext context, String bookingID, String status, int index) async {
    FirestoreService firestoreService = FirestoreService();
    await firestoreService.updateBookingStatus(bookingID, status);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: status == 'accepted'
            ? const Text('Réservation acceptée')
            : const Text('Réservation refusée'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Update UI
    setState(() {
      // Update the booking status in the local list
      _tripBookings[index]['bookingStatus'] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations de voyage'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _tripBookings.isEmpty
                ? _buildNoBookingsWidget()
                : RefreshIndicator(
                    onRefresh: _fetchTripBookings,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      itemCount: _tripBookings.length,
                      itemBuilder: (context, index) {
                        final booking = _tripBookings[index];
                        return FutureBuilder(
                          future: Future.wait([
                            _getTrip(booking['id']),
                            _getUserData(booking['travelerID']),
                          ]),
                          builder:
                              (context, AsyncSnapshot<List<dynamic>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingSkeleton();
                            } else if (snapshot.hasError) {
                              return Text('Erreur: ${snapshot.error}');
                            } else {
                              final List<dynamic>? data = snapshot.data;
                              if (data != null && data.length == 2) {
                                Map<String, dynamic>? trip =
                                    data[0] as Map<String, dynamic>?;
                                Map<String, dynamic>? user =
                                    data[1] as Map<String, dynamic>?;

                                print('------------${booking['startDate']}');
                                String formattedPickupDate =
                                    _formatDate(booking['startDate']);
                                String formattedReturnDate =
                                    _formatDate(booking['endDate']);
                                String formattedPaymentMethod =
                                    _formatPaymentMethod(
                                        booking['paymentMethod']);

                                // Check if the booking status is pending
                                if (booking['bookingStatus'] != 'pending') {
                                  // Skip rendering if the booking status is not pending
                                  return const SizedBox.shrink();
                                }

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  trip?['images']?[0] ?? '',
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
                                                Text(
                                                  '$formattedPickupDate - $formattedReturnDate',
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
                                                  trip?['title'] ?? '',
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
                                                  "${trip?['wilaya']}",
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
                                            'Offert par : ',
                                            style: TextStyle(
                                              color: Color(0xff001939),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '${user?['firstName']} ${user?['lastName'] ?? ''}',
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
                                            'Personnes : ',
                                            style: TextStyle(
                                              color: Color(0xff001939),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Text(
                                            '${booking['people']} people',
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
                                            'Méthode de paiement : ',
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
                                                await _updateBookingStatus(
                                                  context,
                                                  booking['bookingID'],
                                                  'declined',
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
                                                  'Décliner',
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
                                              onPressed: () async {
                                                await _updateBookingStatus(
                                                  context,
                                                  booking['bookingID'],
                                                  'accepted',
                                                  index,
                                                );
                                              },
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
                                                  'Accepter',
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
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                );
                              } else {
                                // Handle null or empty data case
                                return const SizedBox();
                              }
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
        message: "Aucune demande de réservation pour le moment");
  }
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
          return ListTile(
            leading: Container(
              width: 48,
              height: 48,
              color: Colors.white,
            ),
            title: Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
            ),
            subtitle: Container(
              width: double.infinity,
              height: 16,
              color: Colors.white,
            ),
            trailing: Container(
              width: 48,
              height: 48,
              color: Colors.white,
            ),
          );
        },
      ),
    ),
  );
}
