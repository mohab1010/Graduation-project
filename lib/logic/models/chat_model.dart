import 'package:supabase_flutter/supabase_flutter.dart';

class ChatModel {
  final String id;
  final String currentUserId;
  final String? currentUserName;
  final String chatPartnerId;
  final String? chatPartnerName;
  final String? chatPartnerImage;
  final String? currentUserImage;

  /// The Supabase UUID of the person to call (set at chat-open time).
  final String callTargetId;

  ChatModel({
    required this.id,
    required this.chatPartnerId,
    required this.currentUserId,
    required this.callTargetId,
    this.currentUserName,
    this.chatPartnerName,
    this.chatPartnerImage,
    this.currentUserImage,
  });

  /// Used when parent opens chat from chat list.
  /// Doctor is always currentUserId → parent calls the doctor.
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final myId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final doctorId = json['doctor_id'] as String;
    final parentId = json['parent_id'] as String;
    // Whoever I'm NOT is who I call
    final callTarget = myId == doctorId ? parentId : doctorId;
    return ChatModel(
      id: json['id'],
      currentUserId: doctorId,
      chatPartnerId: parentId,
      callTargetId: callTarget,
      currentUserName: json['doctor_name'],
      chatPartnerName: json['parent_name'],
      currentUserImage: json['doctor_image'],
      chatPartnerImage: json['parent_image'],
    );
  }

  toJson() => {
        'id': id,
        'doctor_id': currentUserId,
        'parent_id': chatPartnerId,
        'parent_name': chatPartnerName,
        'doctor_name': currentUserName,
        'parent_image': chatPartnerImage,
        'doctor_image': currentUserImage,
      };
}
