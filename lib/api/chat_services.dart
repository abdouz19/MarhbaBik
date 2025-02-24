import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/models/message.dart';

class ChatService {
  // get instance of  firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // get user stream

  Stream<List<Map<String, dynamic>>> getUsersInBookingsStream(
      String currentUserID) {
    return _firestore
        .collection('bookings')
        .where(Filter.or(
          Filter("travelerID", isEqualTo: currentUserID),
          Filter("targetID", isEqualTo: currentUserID),
        ))
        .snapshots()
        .asyncMap((bookingSnapshot) async {
      Set<String> userIds = {};

      for (var booking in bookingSnapshot.docs) {
        var data = booking.data();
        userIds.add(data['travelerID']);
        userIds.add(data['targetID']);
      }

      // Remove the current user from the list
      userIds.remove(currentUserID);

      if (userIds.isEmpty) return [];

      // Fetch user details from 'users' collection
      var usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds.toList())
          .get();

      return usersSnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // send message

  Future<void> sendMessage(String receiverID, String message) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Ensure we handle nullability
    String currentUserEmail =
        await _firestoreService.getUserEmailById(currentUser.uid) ?? "Unknown";
    final Timestamp timestamp = Timestamp.now();

    // Create new message
    Message newMessage = Message(
      senderId: currentUser.uid,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct a chat roome ID for the two users
    List<String> ids = [currentUser.uid, receiverID];
    ids.sort(); // sort the ids (this ensure chatroomeID is the same for any 2 users)

    String chatRoomID = ids.join("_");

    //add new message to the database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  // getting messages

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroomID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<String> getLastMessageStream(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first['message'] as String;
      }
      return "Pour chatter, touchez ici";
    });
  }

  Future<DateTime?> getLastMessageTime(String currentUserId, String userId) async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(currentUserId)
        .collection('messages')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1);

    final querySnapshot = await chatRef.get();
    if (querySnapshot.docs.isNotEmpty) {
      return (querySnapshot.docs.first['timestamp'] as Timestamp).toDate();
    }
    return null;
  }

}
