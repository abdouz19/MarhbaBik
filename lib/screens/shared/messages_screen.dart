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
          const SizedBox(height: 16), // Optional spacing at the top
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text('Loading..'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(snapshot.data![index], context);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox();

    return FutureBuilder<String?>(
      future: _firestoreService.getUserEmailById(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const SizedBox();
        }

        if (userData['email'] == snapshot.data) {
          return const SizedBox();
        }

        return UserTile(
          text: userData['email'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receivedEmail: userData['email'],
                  receiverID: userData['uid'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}




/* SizedBox(
                child: Image.asset('assets/images/message_illustration.png'),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Fonctionnalité de messagerie en cours de développement',
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
              ),*/
