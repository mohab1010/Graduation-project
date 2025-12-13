import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadImage({
    required File file,
    required String userId,
  }) async {
    final fileName =
        'add_child_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage.from('add_child_images').upload(fileName, file);
    return _supabase.storage.from('add_child_images').getPublicUrl(fileName);
  }

  Future<void> insertChild({
    required String parentId,
    required String name,
    required String gender,
    required String birthdate,
    required int age,
    required String diagnosis,
    required String hobbies,
    String? imageUrl,
  }) async {
    await _supabase.from('children').insert({
      'parent_id': parentId,
      'name': name,
      'gender': gender,
      'birthdate': birthdate.isEmpty ? null : birthdate,
      'age': age,
      'diagnosis': diagnosis,
      'hobbies': hobbies,
      'image_url': imageUrl ?? '',
    });
  }

  // Future<String?> saveChildData({
  //   required String name,
  //   required String gender,
  //   required String birthdate,
  //   required int age,
  //   required String diagnosis,
  //   required String hobbies,
  //   File? imageFile,
  // }) async {
  //   final user = _supabase.auth.currentUser;
  //   if (user == null) return null;

  //   final prefs = await SharedPreferences.getInstance();
  //   final parentId = prefs.getString('parent_id');
  //   if (parentId == null) return null;

  //   String? imageUrl;
  //   if (imageFile != null) {
  //     imageUrl = await uploadImage(file: imageFile, userId: user.id);
  //   }

  //   await insertChild(
  //     parentId: parentId,
  //     name: name,
  //     gender: gender,
  //     birthdate: birthdate,
  //     age: age,
  //     diagnosis: diagnosis,
  //     hobbies: hobbies,
  //     imageUrl: imageUrl,
  //   );

  //   return imageUrl;
  // }
  Future<Map<String, dynamic>?> saveChildData({
    required String name,
    required String gender,
    required String birthdate,
    required int age,
    required String diagnosis,
    required String hobbies,
    File? imageFile,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString('parent_id');
    if (parentId == null) return null;

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await uploadImage(file: imageFile, userId: user.id);
    }

    // هون منرجع الصف المضاف مشان ناخد الـ id
    final response = await _supabase
        .from('children')
        .insert({
          'parent_id': parentId,
          'name': name,
          'gender': gender,
          'birthdate': birthdate,
          'age': age,
          'diagnosis': diagnosis,
          'hobbies': hobbies,
          'image_url': imageUrl,
        })
        .select('id, image_url')
        .single(); // <–– هي أهم سطر

    return {'id': response['id'], 'imageUrl': response['image_url']};
  }
}
