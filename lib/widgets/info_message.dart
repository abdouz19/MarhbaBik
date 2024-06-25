import 'package:flutter/material.dart';

class InfoMessageWidget extends StatelessWidget {
  final IconData iconData;
  final String message;
  final void Function()? onTap;
  const InfoMessageWidget({
    super.key,
    required this.iconData,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty.png',
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: InkWell(
              onTap: onTap,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  color: Color(0xff001939),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'KastelovAxiforma',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
