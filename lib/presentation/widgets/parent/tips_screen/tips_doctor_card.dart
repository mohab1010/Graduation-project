import 'package:wesal/logic/services/colors_app.dart';
import 'package:flutter/material.dart';

class TipsDoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String content;
  final String? imageUrl;
  final String timeAgo;
  final String avatarUrl;

  const TipsDoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.content,
    required this.timeAgo,
    this.imageUrl,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 18,
                    color: ColorsApp().primaryColor,
                  ),
                  SizedBox(width: 5),
                  SizedBox(
                    width: 150,
                    child: Text(
                      specialty,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              Spacer(),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          leading: Container(
            width: 55,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
              image: DecorationImage(
                image: NetworkImage(
                  avatarUrl.isNotEmpty
                      ? avatarUrl
                      : 'https://via.placeholder.com/150',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        SizedBox(height: 5),

        Text(content, style: const TextStyle(fontSize: 16)),

        SizedBox(height: 10),
        if (imageUrl != null)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),

        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Divider(color: Colors.grey[300], thickness: 1.5),
        ),
      ],
    );
  }
}
