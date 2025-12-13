import 'package:wesal/logic/services/add_tips_services/add_tips_services.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/widgets/parent/add_tips/floatingActionButton_add_tips.dart';
import 'package:wesal/presentation/widgets/parent/tips_screen/tips_doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  final supabase = Supabase.instance.client;

  bool refreshTips = false;
  Future<void> _reloadTips() async {
    setState(() {
      refreshTips = !refreshTips; // فقط لتغيير القيمة وإعادة بناء Future
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: userRole == 'doctor'
          ? FloatingactionbuttonAddTips(onTipAdded: _reloadTips)
          : null,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tips"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: TipService().fetchTips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tips = snapshot.data ?? [];

          if (tips.isEmpty) {
            return const Center(
              child: Text("No tips available", style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];

              final profile = tip['profiles'] ?? {};
              final doctorName = profile['full_name'] ?? 'Unknown Doctor';
              final doctorImage =
                  profile['avatar_url'] ?? 'assets/images/doctors4.jpg';

              final specialty = profile['doctors'] != null
                  ? profile['doctors']['specialty']
                  : 'Unknown Specialty';
              final content = tip['tip_content'] ?? '';
              final imageUrl = tip['image_url'];
              final time = formatTime(tip['created_at']);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TipsDoctorCard(
                  name: doctorName,
                  specialty: specialty,
                  content: content,
                  imageUrl: imageUrl,
                  timeAgo: time,
                  avatarUrl: doctorImage,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
