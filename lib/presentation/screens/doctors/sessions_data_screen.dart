import 'dart:developer';

import 'package:wesal/logic/models/chat_model.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/di/dependancy_injection.dart';
import 'package:wesal/logic/services/notifications/fcm_notification.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/chat/chat_screen.dart';
import 'package:wesal/presentation/widgets/doctors/sessions_data_screen/child_data_sessions.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionsDataScreen extends StatefulWidget {
  final Map<String, dynamic> sessionData;
  final String doctorId;
  const SessionsDataScreen({
    super.key,
    required this.sessionData,
    required this.doctorId,
  });

  @override
  State<SessionsDataScreen> createState() => _SessionsDataScreenState();
}

class _SessionsDataScreenState extends State<SessionsDataScreen> {
  Map<String, dynamic>? childData;
  Map<String, dynamic>? doctorData;
  Map<String, dynamic>? parentData;

  List<dynamic> sessions = [];

  Future<void> fetchChildAndSessions() async {
    final childId = widget.sessionData['child_id'];
    if (childId == null) return;

    final supabase = Supabase.instance.client;

    try {
      final childResponse = await supabase
          .from('children')
          .select()
          .eq('id', childId)
          .single();
      final doctorResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', widget.doctorId)
          .single();

      // Fetch the parent's profile for correct chat avatar
      final parentId = childResponse['parent_id']?.toString();
      Map<String, dynamic>? parentResponse;
      if (parentId != null) {
        parentResponse = await supabase
            .from('profiles')
            .select('id, full_name, avatar_url')
            .eq('id', parentId)
            .maybeSingle();
      }

      setState(() {
        childData = childResponse;
        doctorData = doctorResponse;
        parentData = parentResponse;
        sessions = [widget.sessionData];
      });
    } catch (e) {
      log('❌ Error: $e');
    }
  }

  ////////////////////////////////////////////////////////////////
  String? selectedStatus;

  final List<String> statusOptions = [
    "pending",
    "accepted",
    "rejected",
    "completed",
    "canceled",
  ];
  //////////////////////////////////////////////////////////////
  /////              دالة تحديث حالة الطلب              ///////
  //////////////////////////////////////////////////////////////
  Future<void> updateSessionStatus(String sessionId, String parentId) async {
    try {
      final response = await Supabase.instance.client
          .from('sessions')
          .update({'status': selectedStatus})
          .eq('id', sessionId);

      print("✅ Status updated successfully!");
      final parentResponse = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', parentId)
          .single();
      final tokens = parentResponse['tokens'];
      for (final token in tokens) {
        log(token);
        getIt<NotificationsHelper>().sendNotification(
          title: "${childData!['name']} Session",
          body:
              "Session status updated to $selectedStatus by Dr. ${doctorData!['full_name']}",
          type: "order",
          token: token,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to $selectedStatus ✅")),
      );
    } catch (e) {
      print("❌ Error updating status: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update status ❌")));
    }
  }

  //////////////////////////////////////////////////////////////
  /////              جلب الid تبع الsession             ///////
  //////////////////////////////////////////////////////////////
  Future<List<Map<String, dynamic>>> fetchSessions() async {
    final response = await Supabase.instance.client
        .from('sessions')
        .select('id');
    return List<Map<String, dynamic>>.from(response);
  }

  late String sessionId;
  @override
  void initState() {
    super.initState();
    fetchChildAndSessions();
    sessionId = widget.sessionData['id'].toString();
    print("✅ Session IDddddddddddddddddddddddddddd: $sessionId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: childData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 20),
                  width: double.infinity,
                  height: 330,
                  decoration: BoxDecoration(
                    color: ColorsApp().primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: childData!['image_url'] != null
                            ? NetworkImage(childData!['image_url'])
                            : AssetImage('assets/images/doctors4.jpg')
                                  as ImageProvider,
                      ),
                      SizedBox(height: 5),
                      Text(
                        childData!['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        childData!['gender'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.phone_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 2,
                            color: Colors.white70,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to chat screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      chatModel: ChatModel(
                                        chatPartnerId: childData!['parent_id'].toString(),
                                        chatPartnerName: parentData?['full_name'] ?? childData!['name'],
                                        chatPartnerImage: parentData?['avatar_url'],
                                        currentUserId: doctorData!['id'],
                                        currentUserImage: doctorData!['avatar_url'],
                                        currentUserName: doctorData!['full_name'],
                                        id: doctorData!['id'] + childData!['parent_id'].toString(),
                                        callTargetId: childData!['parent_id'].toString(),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.chat_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ChildDataSessions(
                          title: "Age",
                          subTitle: childData!['age'].toString(),
                        ),
                        ChildDataSessions(
                          title: "Birth Date",
                          subTitle: childData!['birthdate'],
                        ),
                        ChildDataSessions(
                          title: "Diagnosis",
                          subTitle: childData!['diagnosis'],
                        ),
                        ChildDataSessions(
                          title: "Hobbies",
                          subTitle: childData!['hobbies'],
                        ),

                        ////////////////////////////////////////////////////////////
                        ...sessions.map((s) {
                          return Column(
                            children: [
                              ChildDataSessions(
                                title: "Session Title",
                                subTitle: s['title'] ?? '',
                              ),
                              ChildDataSessions(
                                title: "Description",
                                subTitle: s['description'] ?? '',
                              ),
                              ChildDataSessions(
                                title: "Scheduled At",
                                subTitle: formatLocalDate(
                                  s['scheduled_at'] ?? '',
                                ),
                              ),
                              ChildDataSessions(
                                title: "Duration Minutes",
                                subTitle: (s['duration_minutes'] ?? 0)
                                    .toString(),
                              ),
                              ChildDataSessions(
                                title: "Status",
                                subTitle: s['status'] ?? '',
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                userRole == 'doctor'
                    ? Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Session Status',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF3789C3),
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.grey[600]),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.flag,
                                        color: ColorsApp().primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 24,
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // initialValue: selectedStatus,
                              items: statusOptions
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => selectedStatus = value);
                              },
                            ),
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: EdgeInsets.only(
                              left: 15,
                              right: 15,
                              bottom: 10,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                if (selectedStatus == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Please select a status first!",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                updateSessionStatus(
                                  sessionId,
                                  childData!['parent_id'],
                                ); //ID الجلسة
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3789C3),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
              ],
            ),
    );
  }
}
