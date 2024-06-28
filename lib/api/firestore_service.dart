import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marhba_bik/models/car.dart';
import 'package:marhba_bik/models/destination.dart';
import 'package:marhba_bik/models/house.dart';
import 'package:marhba_bik/models/trip.dart';
import 'package:marhba_bik/models/wilaya.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // helper functions
  Future<List<T>> _fetchData<T>(
    String collectionName,
    T Function(DocumentSnapshot<Object?> doc) fromDocument,
  ) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();
      return querySnapshot.docs.map((doc) => fromDocument(doc)).toList();
    } catch (e) {
      print("Error fetching $collectionName: $e");
      return [];
    }
  }

  Future<List<T>> _fetchDatas<T>(
    String collectionName,
    T Function(DocumentSnapshot<Object?> doc) fromDocument, {
    String? where,
    dynamic isEqualTo,
    List<String>? whereIn,
  }) async {
    try {
      Query query = FirebaseFirestore.instance.collection(collectionName);
      if (where != null && isEqualTo != null) {
        query = query.where(where, isEqualTo: isEqualTo);
      }
      if (whereIn != null) {
        query = query.where(FieldPath.documentId, whereIn: whereIn);
      }
      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => fromDocument(doc)).toList();
    } catch (e) {
      print("Error fetching $collectionName: $e");
      return [];
    }
  }

  //---------------------------------------------------------------//

  Future<List<Trip>> fetchTrips() async {
    return _fetchData<Trip>('trips', (doc) => Trip.fromDocument(doc));
  }

  Future<List<Car>> fetchCars() async {
    return _fetchData<Car>('cars', (doc) => Car.fromDocument(doc));
  }

  Future<List<House>> fetchHouses() async {
    return _fetchData<House>('houses', (doc) => House.fromDocument(doc));
  }

  Future<List<Wilaya>> fetchWilayas() async {
    return _fetchData<Wilaya>('wilayas', (doc) => Wilaya.fromDocument(doc));
  }

  Future<List<Destination>> fetchDestinations() async {
    return _fetchDatas<Destination>(
        'destinations', (doc) => Destination.fromDocument(doc));
  }

  Future<List<Wilaya>> fetchSpecialWilayas(List<String> wilayaIds) async {
    return _fetchDatas<Wilaya>('wilayas', (doc) => Wilaya.fromDocument(doc),
        whereIn: wilayaIds);
  }

  Future<List<Destination>> fetchSpecialDestinations(
      List<String> destinationNames) async {
    return _fetchDatas<Destination>(
        'destinations', (doc) => Destination.fromDocument(doc),
        whereIn: destinationNames);
  }

  Future<List<Destination>> fetchDestinationsByWilaya(String wilayaName) async {
    return _fetchDatas<Destination>(
        'destinations', (doc) => Destination.fromDocument(doc),
        where: 'wilaya', isEqualTo: wilayaName);
  }

  //---------------------------------------------------------------//

  Future<Wilaya?> fetchSpecialWilaya(String wilayaId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wilayas')
          .where('wilayaID', isEqualTo: wilayaId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Wilaya.fromDocument(querySnapshot.docs.first);
      } else {
        print("No Wilaya found with the given ID");
        return null;
      }
    } catch (e) {
      print("Error fetching Wilaya: $e");
      return null;
    }
  }

  Future<List<int>> loadRatingsForDestination(String destinationName) async {
    try {
      final reviewsDoc = await FirebaseFirestore.instance
          .collection('DestinationsReviews')
          .doc(destinationName)
          .get();
      if (reviewsDoc.exists) {
        final reviewsData = reviewsDoc.data() as Map<String, dynamic>;
        if (reviewsData.containsKey('ratings')) {
          final ratingsData = reviewsData['ratings'];
          if (ratingsData is List<dynamic>) {
            return List<int>.from(ratingsData.cast<int>());
          }
        }
      }
      return [0]; // Default rating if no ratings are found
    } catch (e) {
      print("Error fetching ratings for destination $destinationName: $e");
      return [0]; // Default rating in case of error
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['role'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDocumentById(
      String collection, String docId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> docData =
            docSnapshot.data() as Map<String, dynamic>;
        return docData;
      } else {
        print("$collection document with ID $docId not found");
        return null;
      }
    } catch (e) {
      print("Error fetching $collection data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCarById(String carId) async {
    return getDocumentById('cars', carId);
  }

  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    return getDocumentById('trips', tripId);
  }

  Future<Map<String, dynamic>?> getHouseById(String houseId) async {
    return getDocumentById('houses', houseId);
  }

  Future<T?> getModelById<T>(
    String collection,
    String docId,
    T Function(DocumentSnapshot) fromDocument,
  ) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection(collection).doc(docId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        return fromDocument(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching $collection by ID: $e");
      return null;
    }
  }

  Future<Car?> getCarModelById(String carId) async =>
      getModelById<Car>('cars', carId, Car.fromDocument);

  Future<House?> getHouseModelById(String houseId) async =>
      getModelById<House>('houses', houseId, House.fromDocument);

  Future<Trip?> getTripModelById(String tripId) async =>
      getModelById<Trip>('trips', tripId, Trip.fromDocument);

  Future<Wilaya?> getWilayaModelById(String wilayaId) async =>
      getModelById<Wilaya>('wilayas', wilayaId, Wilaya.fromDocument);

  Future<Destination?> getDestinationModelById(String destinationId) async =>
      getModelById<Destination>(
          'destinations', destinationId, Destination.fromDocument);

  Future<String> uploadBookingCars({
    required String carID,
    required String travelerID,
    required String targetID,
    required String targetType,
    required String bookingStatus,
    required int price,
    required int commission,
    required int totalPrice,
    required int days,
    required String pickupDate,
    required String returnDate,
    required String paymentMethod,
  }) async {
    try {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('bookings').add({
        'id': carID,
        'travelerID': travelerID,
        'targetID': targetID,
        'targetType': targetType,
        'bookingStatus': bookingStatus,
        'price': price,
        'commission': commission,
        'totalPrice': totalPrice,
        'days': days,
        'pickupDate': pickupDate,
        'returnDate': returnDate,
        'paymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Booking uploaded successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error uploading booking: $e");
      return '';
    }
  }

  Future<String> uploadBookingHouses({
    required String houseId,
    required String travelerID,
    required String targetID,
    required String targetType,
    required String bookingStatus,
    required int price,
    required int commission,
    required int totalPrice,
    required int nights,
    required String pickupDate,
    required String returnDate,
    required String paymentMethod,
    required int guests,
  }) async {
    try {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('bookings').add({
        'id': houseId,
        'travelerID': travelerID,
        'targetID': targetID,
        'targetType': targetType,
        'bookingStatus': bookingStatus,
        'price': price,
        'commission': commission,
        'totalPrice': totalPrice,
        'nights': nights,
        'guests': guests,
        'pickupDate': pickupDate,
        'returnDate': returnDate,
        'paymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Booking uploaded successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error uploading booking: $e");
      return '';
    }
  }

  Future<String> uploadBookingTrips({
    required String tripId,
    required String travelerID,
    required String targetID,
    required String targetType,
    required String bookingStatus,
    required int price,
    required int commission,
    required int totalPrice,
    required Timestamp startDate,
    required Timestamp endDate,
    required int people,
    required String paymentMethod,
  }) async {
    try {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('bookings').add({
        'id': tripId,
        'travelerID': travelerID,
        'targetID': targetID,
        'targetType': targetType,
        'bookingStatus': bookingStatus,
        'price': price,
        'commission': commission,
        'totalPrice': totalPrice,
        'startDate': startDate,
        'endDate': endDate,
        'people': people,
        'paymentMethod': paymentMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Booking uploaded successfully with ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error uploading booking: $e");
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> fetchBookingByTarget(
      String userID, String targetType, String collectionName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('targetType', isEqualTo: targetType)
          .where('targetID', isEqualTo: userID)
          .where('bookingStatus', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> bookings = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> bookingData = doc.data() as Map<String, dynamic>;
        String targetID = bookingData['id'];

        DocumentSnapshot targetSnapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(targetID)
            .get();

        if (targetSnapshot.exists) {
          bookings.add(bookingData);
        }
      }

      return bookings;
    } catch (e) {
      print("Error fetching $targetType bookings: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchBookingCars(String userID) async {
    return fetchBookingByTarget(userID, 'cars', 'cars');
  }

  Future<List<Map<String, dynamic>>> fetchBookingHouses(String userID) async {
    return fetchBookingByTarget(userID, 'houses', 'houses');
  }

  Future<List<Map<String, dynamic>>> fetchBookingTrips(String userID) async {
    return fetchBookingByTarget(userID, 'trips', 'trips');
  }

  // Helper function to fetch document by ID
  Future<Map<String, dynamic>?> _getDocumentById(
      String collectionName, String docId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        print("$collectionName document with ID $docId not found");
        return null;
      }
    } catch (e) {
      print("Error fetching $collectionName data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserDataById(String userID) async {
    return _getDocumentById('users', userID);
  }

  Future<Map<String, dynamic>?> getDestinationById(String destinationId) async {
    return _getDocumentById('destinations', destinationId);
  }

  Future<Map<String, dynamic>?> getWilayaById(String wilayaId) async {
    return _getDocumentById('wilayas', wilayaId);
  }

  Future<Wilaya> fetchWilayaByName(String wilayaName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wilayas')
          .where('name', isEqualTo: wilayaName)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return Wilaya.fromDocument(querySnapshot.docs.first);
      } else {
        throw Exception("Wilaya not found");
      }
    } catch (e) {
      print("Error fetching wilaya: $e");
      throw e;
    }
  }

  Future<List<String>> getDestinationImagesByWilaya(String wilayaName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('destinations')
          .where('wilaya', isEqualTo: wilayaName)
          .get();

      List<String> imageUrls = [];
      for (var doc in snapshot.docs) {
        List<dynamic> urls = doc['otherPicturesUrls'];
        imageUrls.addAll(urls.cast<String>());
      }

      return imageUrls;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<Destination>> getDestinationsByRegion(String region) async {
    try {
      // Convert the entered region value to lowercase
      String normalizedRegion = region.toLowerCase();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('destinations')
          .where('region', isEqualTo: normalizedRegion)
          .get();

      List<Destination> destinations = querySnapshot.docs
          .map((doc) => Destination.fromDocument(doc))
          .toList();

      return destinations;
    } catch (e) {
      print("Error fetching destinations: $e");
      return [];
    }
  }

// Function to fetch houses by wilaya
  Future<List<House>> fetchHousesByWilaya(String wilaya) async {
    return _fetchDatas<House>(
      'houses',
      (doc) => House.fromDocument(doc),
      where: 'wilaya',
      isEqualTo: wilaya,
    );
  }

  Future<List<Trip>> fetchTripsByWilaya(String wilaya) async {
    return _fetchDatas<Trip>(
      'trips',
      (doc) => Trip.fromDocument(doc),
      where: 'wilaya',
      isEqualTo: wilaya,
    );
  }

  Future<List<Car>> fetchCarsByWilaya(String wilaya) async {
    return _fetchDatas<Car>(
      'cars',
      (doc) => Car.fromDocument(doc),
      where: 'wilaya',
      isEqualTo: wilaya,
    );
  }

  Future<List<Wilaya>> getWilayasByRegion(String region) async {
    try {
      // Convert the entered region value to lowercase
      String normalizedRegion = region.toLowerCase();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('wilayas')
          .where('regions', arrayContains: normalizedRegion)
          .get();

      List<Wilaya> wilayas =
          querySnapshot.docs.map((doc) => Wilaya.fromDocument(doc)).toList();

      return wilayas;
    } catch (e) {
      print("Error fetching wilayas: $e");
      return [];
    }
  }

  Future<void> updateBookingStatus(String bookingID, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingID)
          .update({
        'bookingStatus': status,
      });
      print('Booking status updated to $status');
    } catch (e) {
      print('Error updating booking status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBookingsByTravelerID(
      String travelerID, String targetType, String collectionName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('travelerID', isEqualTo: travelerID)
          .where('targetType', isEqualTo: targetType)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> bookings = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> bookingData = doc.data() as Map<String, dynamic>;
        String targetID = bookingData['id'];

        DocumentSnapshot targetSnapshot = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(targetID)
            .get();

        if (targetSnapshot.exists) {
          bookings.add(bookingData);
        }
      }

      return bookings;
    } catch (e) {
      print("Error fetching $targetType bookings: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCarBookingsByTravelerID(
      String travelerID) async {
    return fetchBookingsByTravelerID(travelerID, 'cars', 'cars');
  }

  Future<List<Map<String, dynamic>>> fetchHouseBookingsByTravelerID(
      String travelerID) async {
    return fetchBookingsByTravelerID(travelerID, 'houses', 'houses');
  }

  Future<List<Map<String, dynamic>>> fetchTripBookingsByTravelerID(
      String travelerID) async {
    return fetchBookingsByTravelerID(travelerID, 'trips', 'trips');
  }

  Future<void> deleteBooking(String bookingID) async {
    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(bookingID)
        .delete();
  }

  Future<void> cancelBooking(String bookingID) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingID)
          .update({'bookingStatus': 'canceled'});
    } catch (e) {
      // Handle error
      print('Error canceling booking: $e');
    }
  }

  Future<void> addToWishlist(String itemId, String collection) async {
    // Get the current user ID
    String currentUserId = await getCurrentUserId();

    // Check if wishlist document exists for the user
    DocumentReference wishlistRef =
        FirebaseFirestore.instance.collection('wishlists').doc(currentUserId);
    DocumentSnapshot wishlistSnapshot = await wishlistRef.get();

    if (wishlistSnapshot.exists) {
      // Construct the field name dynamically within the update data
      String fieldToUpdate = '${collection}Ids';
      Map<String, dynamic> updateData = {
        fieldToUpdate: FieldValue.arrayUnion([itemId])
      };

      await wishlistRef.update(updateData);
    } else {
      // Create a new wishlist document with an empty array for the collection
      String fieldToUpdate =
          '${collection}Ids'; // Define fieldToUpdate within the else block
      await wishlistRef.set({
        fieldToUpdate: [], // Initialize with an empty array
        'userId': currentUserId, // Add the user ID field
      });

      // Then, add the item to the newly created array using another call to addToWishlist
      await addToWishlist(
          itemId, collection); // Recursive call to add the first item
    }
  }

  Future<void> removeFromWishlist(String itemId, String collection) async {
    // Get the current user ID
    String currentUserId = await getCurrentUserId();

    // Check if wishlist document exists for the user
    DocumentReference wishlistRef =
        FirebaseFirestore.instance.collection('wishlists').doc(currentUserId);
    DocumentSnapshot wishlistSnapshot = await wishlistRef.get();

    if (wishlistSnapshot.exists) {
      // Wishlist document exists, update the appropriate array field
      String fieldToUpdate =
          '${collection}Ids'; // Construct field name dynamically
      List<String> itemIds =
          wishlistSnapshot.get(fieldToUpdate)?.cast<String>() ?? [];
      if (itemIds.contains(itemId)) {
        itemIds.remove(itemId);
        await wishlistRef.update({fieldToUpdate: itemIds});
      }
      // Not present, handle it if needed (e.g., show a toast)
    } else {
      // No wishlist document, nothing to remove
    }
  }

  Future<bool> isItemFavorited(String itemId, String collection) async {
    String currentUserId = await getCurrentUserId();
    DocumentReference wishlistRef =
        FirebaseFirestore.instance.collection('wishlists').doc(currentUserId);
    DocumentSnapshot wishlistSnapshot = await wishlistRef.get();

    if (wishlistSnapshot.exists) {
      String fieldToCheck =
          '${collection}Ids'; // Construct field name dynamically
      List<String> itemIds =
          wishlistSnapshot.get(fieldToCheck)?.cast<String>() ?? [];
      return itemIds.contains(itemId);
    } else {
      return false; // No wishlist or item not present
    }
  }

  Future<String> getCurrentUserId() async {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  Future<Map<String, List<String>>> getWishlistData(String userId) async {
    // Get the wishlist document for the current user
    DocumentSnapshot wishlistSnapshot = await FirebaseFirestore.instance
        .collection('wishlists')
        .doc(userId)
        .get();

    if (!wishlistSnapshot.exists) {
      return {}; // Return an empty map if no wishlist document
    }

    // Extract wishlist data, checking for empty arrays
    final wishlistData = wishlistSnapshot.data() as Map<String, dynamic>;
    Map<String, List<String>> formattedData = {};
    wishlistData.forEach((collectionName, itemIds) {
      if (itemIds is List && itemIds.isNotEmpty) {
        formattedData[collectionName] = itemIds.cast<String>();
      }
    });

    return formattedData;
  }

  Future<void> saveSubscription(
      String userId, Map<String, dynamic> data) async {
    try {
      // Check if the document exists
      final docSnapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        // Update the existing document with new data
        await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(userId)
            .update(data);
      } else {
        // If the document doesn't exist, create a new one
        await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(userId)
            .set(data);
      }
    } catch (e) {
      throw Exception('Failed to save subscription: $e');
    }
  }

  Future<bool> checkSubscriptionPayment(String userId) async {
    try {
      QuerySnapshot subscriptionSnapshot = await FirebaseFirestore.instance
          .collection('subscriptions')
          .where('userId', isEqualTo: userId)
          .get();

      if (subscriptionSnapshot.docs.isNotEmpty) {
        var subscriptionData = subscriptionSnapshot.docs.first.data();

        // Cast subscriptionData to Map<String, dynamic>
        Map<String, dynamic>? dataMap =
            subscriptionData as Map<String, dynamic>?;

        if (dataMap != null && dataMap.containsKey('expiration_date')) {
          String? expirationDateString = dataMap['expiration_date'];

          if (expirationDateString != null) {
            DateTime expirationDate = DateTime.parse(expirationDateString);
            DateTime currentDate = DateTime.now();

            if (currentDate.isBefore(expirationDate) ||
                currentDate.isAtSameMomentAs(expirationDate)) {
              return true;
            } else {
              return false;
            }
          }
        }
      }
      // User has no subscription or expiration date is missing
      return false;
    } catch (e) {
      print('Error checking subscription payment: $e');
      return false;
    }
  }

  Future<int> countBookingsById(String id) async {
    int count = 0;

    try {
      // Query for bookings where the ID is found in targetID and bookingStatus is "accepted"
      QuerySnapshot targetQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('targetID', isEqualTo: id)
          .where('bookingStatus', isEqualTo: 'accepted')
          .get();

      // Query for bookings where the ID is found in travelerID and bookingStatus is "accepted"
      QuerySnapshot travelerQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('travelerID', isEqualTo: id)
          .where('bookingStatus', isEqualTo: 'accepted')
          .get();

      // Sum the counts from both queries
      count = targetQuery.docs.length + travelerQuery.docs.length;
    } catch (e) {
      print('Error counting bookings: $e');
    }

    return count;
  }
}
