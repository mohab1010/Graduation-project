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

  Future<void> updateProfile(BuildContext context) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final updates = {
      'full_name': editeProfileName.text.trim(),
      'email': editProfileEmail.text.trim(),
      'phone': editProfilePhone.text.trim(),
    };

    final response = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.id);

    print(response); // Debug

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile updated successfully')),
      );
    }
  }
}
