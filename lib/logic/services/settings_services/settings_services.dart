import 'dart:io';

import 'package:wesal/logic/services/variables_app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await supabase
          .from('profiles')
          .select('full_name, email, phone, avatar_url')
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print("❌ Error fetching profile: $e");
      return null;
    }
  }

  Future<String?> uploadAvatar(File imageFile, String userId) async {
    final fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await supabase.storage
        .from('profiles_images')
        .upload(fileName, imageFile, fileOptions: const FileOptions(upsert: true));
    return supabase.storage.from('profiles_images').getPublicUrl(fileName);
  }

  Future<void> updateProfile(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      String? avatarUrl;
      if (selectedImage != null) {
        avatarUrl = await uploadAvatar(selectedImage!, user.id);
      }

      final updates = <String, dynamic>{
        'full_name': editeProfileName.text.trim(),
        'phone': editProfilePhone.text.trim(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      await supabase.from('profiles').update(updates).eq('id', user.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Profile updated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to update profile: $e')),
        );
      }
    }
  }
}
