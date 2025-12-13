import 'package:flutter/material.dart';

class ChildDataSessions extends StatelessWidget {
  final String title;
  final String subTitle;

  const ChildDataSessions({
    super.key,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(subTitle, style: TextStyle(fontSize: 16, color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Divider(color: Colors.grey[300], thickness: 1.5),
          ),
        ],
      ),
    );
  }
}
