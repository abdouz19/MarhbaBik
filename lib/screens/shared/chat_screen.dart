import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marhba_bik/api/chat_services.dart';
import 'package:marhba_bik/components/chat_bubble.dart';
import 'package:marhba_bik/components/message_textfield.dart';

class ChatPage extends StatefulWidget {
  final String receivedEmail;
  final String receiverID;

  const ChatPage(
      {super.key, required this.receivedEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Text controller & Chat Service
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  // Focus & Scroll Controllers
  final FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Scroll down when keyboard opens
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), scrollDown);
      }
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to the bottom of messages
  void scrollDown() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverID, _messageController.text);
      _messageController.clear();
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receivedEmail)),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()), // Display messages
          buildUserInput(), // Message input field
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error');
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Text('Loading...');

        WidgetsBinding.instance.addPostFrameCallback(
            (_) => scrollDown()); // Auto-scroll when new messages load

        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == currentUser!.uid;
    return Container(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ChatBubble(
        isCurrentUser: isCurrentUser,
        message: data['message'],
      ),
    );
  }

  Widget buildUserInput() {
    return MessageTextField(
      focusNode: myFocusNode,
      hintText: 'Écrit un message...',
      controller: _messageController,
      onSend: sendMessage,
    );
  }
}
