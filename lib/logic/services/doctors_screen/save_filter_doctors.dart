import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class DoctorService {
  final _supabase = Supabase.instance.client;

  /// 🔹 تحميل جميع الدكاترة
  Future<List<dynamic>> loadDoctors() async {
    try {
      final response = await _supabase.from('doctors').select(
            'id, specialty, qualification, clinic_address, bio, profiles(full_name, avatar_url, role, tokens)',
          );

      final doctorList = response
          .where((doc) => doc['profiles']?['role'] == 'doctor')
          .toList();

      debugPrint('✅ Loaded ${doctorList.length} doctors');
      return doctorList;
    } catch (e) {
      debugPrint('❌ Error loading doctors: $e');
      return [];
    }
  }

  /// 🔹 فلترة حسب التخصص
  Future<List<dynamic>> filterDoctors(String specialty) async {
    try {
      final response = await _supabase
          .from('doctors')
          .select(
            'id, specialty, qualification, clinic_address, bio, profiles(full_name, avatar_url, role, tokens)',
          )
          .eq('specialty', specialty);

      final doctorList = response
          .where((doc) => doc['profiles']?['role'] == 'doctor')
          .toList();

      debugPrint('✅ Filtered ${doctorList.length} doctors');
      return doctorList;
    } catch (e) {
      debugPrint('❌ Error filtering doctors: $e');
      return [];
    }
  }

  /// 🔹 بحث بالاسم
  List<dynamic> searchDoctors(List<dynamic> doctors, String query) {
    final lowerQuery = query.toLowerCase();
    return doctors.where((doc) {
      final name =
          doc['profiles']?['full_name']?.toString().toLowerCase() ?? '';
      return name.contains(lowerQuery);
    }).toList();
  }
}
