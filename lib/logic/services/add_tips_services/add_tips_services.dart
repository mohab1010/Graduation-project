import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class TipService {
  final supabase = Supabase.instance.client;
  final bucket = "add_tips_images";

  Future<String?> uploadImage({
    required File file,
    required String userId,
  }) async {
    final fileName =
        'add_tips_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage.from(bucket).upload(fileName, file);
    return supabase.storage.from(bucket).getPublicUrl(fileName);
  }

  Future<bool?> insertTip({
    required String doctorId,
    required String tipContent,
    File? imageFile,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(file: imageFile, userId: user.id);
    }
    try {
      await supabase.from("tips").insert({
        "doctor_id": doctorId,
        "tip_content": tipContent,
        "image_url": imageUrl,
      });

      return true;
    } catch (e) {
      print("Insert Tip Error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTips() async {
    final response = await supabase
        .from('tips')
        .select('''
      tip_content,
      image_url,
      created_at,
      profiles:doctor_id(
        full_name,
        avatar_url,
        doctors!inner(
          specialty
        )
      )
    ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
