import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marhba_bik/api/chat_services.dart';
import 'package:marhba_bik/components/message_textfield.dart';
import 'package:marhba_bik/components/textfield.dart';

class ChatPage extends StatelessWidget {
  final String receivedEmail;
  final String receiverID;

  ChatPage({super.key, required this.receivedEmail, required this.receiverID});

  // text controller
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void sendMessage() async {
    // if there's seomthing to send inside the textfield
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(receiverID, _messageController.text);

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receivedEmail),
      ),
      body: Column(
        children: [
          //displaying the messages
          Expanded(
            child: _buildMessageList(),
          ),
          // displaying user input
          buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
        stream: _chatService.getMessages(receiverID, currentUser!.uid),
        builder: (context, snapshot) {
          // errord
          if (snapshot.hasError) {
            return const Text('Error');
          }
          // loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          // return listview
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data['senderID'] == currentUser!.uid;
    // align on the right if dender is current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Container(alignment: alignment,child: Text(data['message']));
  }

  Widget buildUserInput() {
    return Row(
      children: [
        Expanded(
          child: MessageTextField(
            hintText: 'Ecrit un message',
            onSend: sendMessage,
            controller: _messageController,
          ),
        ),
      ],
    );
  }
}
