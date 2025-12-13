import 'package:flutter/material.dart';

class DoctorTitleCard extends StatelessWidget {
  final String title;
  final String subTitle;

  const DoctorTitleCard({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2),
        // اسم الدكتور
        Text(
          subTitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
