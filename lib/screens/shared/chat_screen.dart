import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marhba_bik/api/chat_services.dart';
import 'package:marhba_bik/components/chat_bubble.dart';
import 'package:marhba_bik/components/message_textfield.dart';

class ChatPage extends StatefulWidget {
  final String receiverID;

  const ChatPage({super.key, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        title: _buildUserInfo(),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.receiverID)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const Text("Chat", style: TextStyle(color: Colors.black));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final profilePicture = userData['profilePicture'] ?? '';
        final role = userData['role'] ?? '';
        final bool isAgency = role.toLowerCase() == "travelling agency";

        final displayName = isAgency
            ? (userData['agencyName'] ?? 'Unknown Agency')
            : "${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}"
                .trim();

        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profilePicture.isNotEmpty
                  ? NetworkImage(profilePicture)
                  : const AssetImage('assets/default_avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 10), // Small space between image & text
            Text(
              displayName.isNotEmpty ? displayName : 'Unknown User',
              style: GoogleFonts.poppins(
                color: const Color(0xff001939),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageList() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => scrollDown());

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
