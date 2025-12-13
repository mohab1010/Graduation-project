import 'package:supabase_flutter/supabase_flutter.dart';

class SessionsService {
  final supabase = Supabase.instance.client;

  Future<String?> getChildImage(String childId) async {
    final response = await supabase
        .from("children")
        .select("image_url")
        .eq("id", childId)
        .single();

    return response["image_url"];
  }

  Future<List<Map<String, dynamic>>> getDoctorSessions(
    String doctorId,
    String status,
  ) async {
    try {
      print("DEBUG: getDoctorSessions -> doctorId: $doctorId, status: $status");

      final response = await supabase
          .from('sessions')
          .select(
            'id, title, description, scheduled_at, duration_minutes, status, parent_id, child_id',
          )
          .eq('doctor_id', doctorId)
          .eq('status', status)
          .order('scheduled_at', ascending: false);

      print("DEBUG: supabase response type: ${response.runtimeType}");
      print(
        "DEBUG: supabase response length: ${(response as List).length}",
      );
      print(
        "DEBUG: first item (if any): ${(response as List).isNotEmpty ? (response as List).first : 'NO ITEMS'}",
      );

      return response ?? [];
    } catch (e, st) {
      print("ERROR getDoctorSessions: $e");
      print(st);
      return [];
    }
  }

  ////////////////////////////////////////////////////////////////
  ////// جلب الحجوزات الخاصة بالparent ////////////////////////
  Future<List<dynamic>> getParentSessions(
    String parentId,
    String status,
  ) async {
    final response = await Supabase.instance.client
        .from('sessions')
        .select()
        .eq('parent_id', parentId)
        .eq('status', status)
        .order('scheduled_at', ascending: false);

    print("✅ Parent Sessions Loaded: ${response.length}");
    return response;
  }
}
