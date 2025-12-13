import 'dart:io';
import 'package:wesal/logic/services/di/dependancy_injection.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveProfileUserData {
  final picker = ImagePicker();

  Future<File?> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      return File(picked.path);
    }
    return null;
  }

  Future<String?> uploadImage(File file) async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('No user is currently logged in while uploading the image');
        return null;
      }
      final fileName = userRole == 'doctor'
          ? 'doctor_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg'
          : 'profile_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from(userRole == 'doctor' ? 'doctors_images' : 'profiles_images')
          .upload(fileName, file);

      final publicUrl = Supabase.instance.client.storage
          .from(userRole == 'doctor' ? 'doctors_images' : 'profiles_images')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> saveProfilesData({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required String email,
    required String fullName,
    required String phone,
    required String role,
    File? imageFile,
  }) async {
    if (!formKey.currentState!.validate()) return;

    String? imageUrl;
    final parentUser = Supabase.instance.client.auth.currentUser;
    if (parentUser == null) {
      debugPrint('No user currently logged in');
      return;
    }

    if (imageFile != null) {
      imageUrl = await uploadImage(imageFile);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parent_id', parentUser.id);
    print('✅ Parent ID saved: ${parentUser.id}');

    try {
      final response = await Supabase.instance.client.from('profiles').insert({
        'id': parentUser.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'avatar_url': imageUrl ?? '',
        'role': role,
        "tokens": [await getIt<FirebaseMessaging>().getToken()]
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The data has been saved successfully')),
      );

      return response;
    } catch (e) {
      debugPrint('Insert error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error: $e')));
    }
  }
}
