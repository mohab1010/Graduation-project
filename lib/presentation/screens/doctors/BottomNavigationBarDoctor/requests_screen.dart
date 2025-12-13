import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/sessions_service/sessions_service.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/doctors/sessions_data_screen.dart';
import 'package:wesal/presentation/widgets/doctors/sessions_screen/orders_tabs.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late Future<List<dynamic>> futureSessions;
  String currentStatus = "pending";

  @override
  void initState() {
    super.initState();
    loadDoctorName();
    loadSessions();
  }
  var docId = "";
  void loadSessions() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print("DEBUG: currentUser is null");
      futureSessions = Future.value([]);
      return;
    }

    final doctorId = user.id;
    docId = doctorId;
    print("DEBUG: loadSessions -> doctorId: $doctorId, status: $currentStatus");

    futureSessions = SessionsService().getDoctorSessions(
      doctorId,
      currentStatus,
    );
    setState(() {});
  }

  Future<void> loadDoctorName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', user.id)
          .single();

      setState(() {
        doctorName = response['full_name'] ?? "Doctor";
        doctorImage = response['avatar_url'] ?? 'assets/images/doctors4.jpg';
      });
    } catch (e) {
      print("❌ Error loading doctor name: $e");
      setState(() {
        doctorName = "Doctor";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      doctorImage.isNotEmpty
                          ? doctorImage
                          : 'assets/images/doctors4.jpg',
                    ),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctorName.isNotEmpty ? doctorName : "Doctor",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(
                    Icons.notifications,
                    size: 30,
                    color: ColorsApp().primaryColor,
                  ),
                ],
              ),

              SizedBox(height: 20),
              OrdersTabs(
                onTabChange: (newStatus) {
                  currentStatus = newStatus;
                  loadSessions();
                },
              ),
              SizedBox(height: 25),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: futureSessions,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final sessions = snapshot.data!;

                    if (sessions.isEmpty) {
                      return Center(
                        child: Text(
                          "No Sessions Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Colors.grey[300], thickness: 1.5),
                      ),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final s = sessions[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SessionsDataScreen(
                                  sessionData: s,
                                  doctorId: docId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                FutureBuilder<String?>(
                                  future: SessionsService().getChildImage(
                                    s["child_id"],
                                  ),
                                  builder: (context, imgSnapshot) {
                                    if (!imgSnapshot.hasData) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      );
                                    }

                                    final imageUrl = imgSnapshot.data;

                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey[300],
                                        image: imageUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : const DecorationImage(
                                                image: AssetImage(
                                                  "assets/images/doctors4.jpg",
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s["title"] ?? "Session",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            size: 18,
                                            color: ColorsApp().primaryColor,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            formatLocalDate(s["scheduled_at"]),
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: ColorsApp().primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              "${s["duration_minutes"] ?? '?'} min",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
