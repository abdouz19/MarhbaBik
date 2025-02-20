import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/models/message.dart';

class ChatService {
  // get instance of  firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // get user stream

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList(); // Convert Iterable to List
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
}
