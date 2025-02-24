import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String profilePicture;
  final String displayName;
  final String lastMessage;
  final VoidCallback onTap;

  const UserTile({
    super.key,
    required this.profilePicture,
    required this.displayName,
    required this.lastMessage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[300],
        backgroundImage: profilePicture.isNotEmpty
            ? NetworkImage(profilePicture)
            : const AssetImage('assets/default_avatar.png') as ImageProvider,
      ),
      title: Text(
        displayName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        lastMessage,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(Icons.chat_bubble_outline, color: Colors.blue[400]),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }
}
