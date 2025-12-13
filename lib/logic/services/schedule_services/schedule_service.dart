import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/parents/doctor_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleService {
  final _supabase = Supabase.instance.client;

  Future<void> createSchedule({
    required String title,
    required String description,
    required String scheduledAt,
    required int durationMinutes,
    required String childId,
    required String doctorId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getString('parent_id');

    if (parentId == null) {
      throw Exception('Parent ID not found in SharedPreferences');
    }
    try {
      final response = await _supabase
          .from('sessions')
          .insert({
            'title': title,
            'description': description,
            // ⚠️ لازم نحول النص لتاريخ بصيغة صحيحة
            'scheduled_at': selectedDay!.toIso8601String(),
            'duration_minutes': totalMinutes,
            'child_id': childId,
            'doctor_id': doctorId,
            'parent_id': parentId,
          })
          .select()
          .single();

      print('✅ Schedule created successfully: $response');
    } catch (e) {
      print('❌ Error creating schedule: $e');
      rethrow;
    }
  }
}
