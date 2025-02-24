import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/api/chat_services.dart';
import 'package:marhba_bik/api/firestore_service.dart';
import 'package:marhba_bik/components/user_tile.dart';
import 'package:marhba_bik/screens/shared/chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  MessagesScreen({super.key});

  final ChatService _chatService = ChatService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('User not logged in'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersInBookingsStream(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading users'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return _buildEmptyState();
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getSortedUserList(users, currentUser.uid),
          builder: (context, sortedSnapshot) {
            if (sortedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (sortedSnapshot.hasError || sortedSnapshot.data == null) {
              return const Center(child: Text('Error sorting users'));
            }

            final sortedUsers = sortedSnapshot.data!;
            return ListView.builder(
              itemCount: sortedUsers.length,
              itemBuilder: (context, index) {
                return _buildUserListItem(sortedUsers[index], context);
              },
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getSortedUserList(
      List<Map<String, dynamic>> users, String currentUserId) async {
    List<Map<String, dynamic>> enrichedUsers = [];

    for (var user in users) {
      String userId = user['uid'];

      // Fetch last message timestamp
      DateTime? lastMessageTime =
          await _chatService.getLastMessageTime(currentUserId, userId);

      // Fetch latest booking timestamp
      DateTime? lastBookingTime =
          await _firestoreService.getLastBookingTime(currentUserId, userId);

      // Determine the most recent interaction time
      DateTime latestInteractionTime =
          (lastMessageTime != null && lastBookingTime != null)
              ? (lastMessageTime.isAfter(lastBookingTime)
                  ? lastMessageTime
                  : lastBookingTime)
              : (lastMessageTime ??
                  lastBookingTime ??
                  DateTime.fromMillisecondsSinceEpoch(0));

      // Add to list with latest interaction timestamp
      enrichedUsers.add({
        ...user,
        'latestInteractionTime': latestInteractionTime,
      });
    }

    // Sort users based on latest interaction time (newest first)
    enrichedUsers.sort((a, b) =>
        b['latestInteractionTime'].compareTo(a['latestInteractionTime']));

    return enrichedUsers;
  }
}

Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return const SizedBox();

  final FirestoreService _firestoreService = FirestoreService();
  final ChatService _chatService = ChatService();

  return FutureBuilder<Map<String, dynamic>?>(
    future: _firestoreService.getUserDataById(userData['uid']),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox();
      }

      if (snapshot.hasError || snapshot.data == null) {
        return const SizedBox();
      }

      final userDetails = snapshot.data!;
      final profilePicture =
          userDetails['profilePicture'] ?? ''; // Profile pic URL
      final role =
          userDetails['role'] ?? ''; // Role: "travelling agency" or user
      final bool isAgency = role.toLowerCase() == "travelling agency";

      // Display agencyName if it's an agency, otherwise show first & last name
      final displayName = isAgency
          ? (userDetails['agencyName'] ?? 'Unknown Agency')
          : "${userDetails['firstName'] ?? ''} ${userDetails['lastName'] ?? ''}"
              .trim();

      return StreamBuilder<String>(
        stream:
            _chatService.getLastMessageStream(currentUser.uid, userData['uid']),
        builder: (context, messageSnapshot) {
          String lastMessage = "Pour chatter, touchez ici";
          if (messageSnapshot.hasData) {
            lastMessage = messageSnapshot.data!;
          }

          return UserTile(
            profilePicture: profilePicture,
            displayName: displayName.isNotEmpty ? displayName : 'Unknown User',
            lastMessage: lastMessage,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receiverID: userDetails['uid'],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

Widget _buildEmptyState() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        height: 200,
        child: Image.asset('assets/images/message_illustration.png'),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          "Aucune conversation pour l’instant… Brisez la glace ! ❄️💬",
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Color(0xff001939),
            fontWeight: FontWeight.w700,
            fontFamily: 'KastelovAxiforma',
            fontSize: 20,
          ),
        ),
      ),
    ],
  );
}
