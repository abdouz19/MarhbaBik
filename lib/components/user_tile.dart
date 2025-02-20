import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final VoidCallback? onTap; // Correct function type

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12), // Added padding for better UI
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.white), // Adjusted icon color
            SizedBox(width: 8), // Added spacing between icon and text
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16), // Styled text
            ),
          ],
        ),
      ),
    );
  }
}
