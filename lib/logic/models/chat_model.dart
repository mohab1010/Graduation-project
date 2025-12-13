class ChatModel {
  final String id;
  final String currentUserId;
  final String? currentUserName;
  final String chatPartnerId;
  final String? chatPartnerName;
  final String? chatPartnerImage;
  final String? currentUserImage;

  ChatModel({
    required this.id,
    required this.chatPartnerId,
    required this.currentUserId,
    this.currentUserName,
    this.chatPartnerName,
    this.chatPartnerImage,
    this.currentUserImage,
  });
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      currentUserId: json['doctor_id'],
      chatPartnerId: json['parent_id'],
      chatPartnerName:
          json['parent_name'] == null ? null : json['parent_name'],
      currentUserName: json['doctor_name'] == null ? null : json['doctor_name'],
      chatPartnerImage:
          json['parent_image'] == null ? null : json['parent_image'],
      currentUserImage: json['doctor_image'] == null ? null : json['doctor_image'],
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
