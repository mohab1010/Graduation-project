import 'package:flutter/material.dart';

class CardGridViewWidget extends StatelessWidget {
  final String name;
  final String specialty;
  final String? imageUrl;
  final Map<String, dynamic> doctor;

  const CardGridViewWidget({
    super.key,
    required this.name,
    required this.specialty,
    this.imageUrl,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final profile = doctor['profiles'];
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                offset: const Offset(2, 2),
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 3,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: profile != null && profile['avatar_url'] != null
                        ? NetworkImage(profile['avatar_url'])
                        : const AssetImage('assets/images/doctors4.jpg')
                              as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  profile != null
                      ? profile['full_name'] ?? 'Unknown'
                      : 'Unknown',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Text(
                  doctor['specialty'] ?? 'Unknown specialty',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
