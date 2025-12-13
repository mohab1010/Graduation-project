import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/sessions_service/sessions_service.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/doctors/sessions_data_screen.dart';
import 'package:wesal/presentation/widgets/doctors/sessions_screen/orders_tabs.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MySessionsScreen extends StatefulWidget {
  const MySessionsScreen({super.key});

  @override
  State<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends State<MySessionsScreen> {
  late Future<List<dynamic>> futureSessions;
  String currentStatus = "pending";

  @override
  void initState() {
    super.initState();
    loadParentSessions();
  }

  void loadParentSessions() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      futureSessions = Future.value([]);
      return;
    }

    final parentId = user.id;
    futureSessions = SessionsService().getParentSessions(
      parentId,
      currentStatus,
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "My Sessions",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.calendar_month,
              size: 30,
              color: ColorsApp().primaryColor,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔶 Tabs
              OrdersTabs(
                onTabChange: (newStatus) {
                  currentStatus = newStatus;
                  loadParentSessions();
                },
              ),

              const SizedBox(height: 25),

              // 🔶 Sessions List
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: futureSessions,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
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
                                  doctorId: s["doctor_id"],
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              // 🔹 Child Image
                              FutureBuilder<String?>(
                                future: SessionsService().getChildImage(
                                  s["child_id"],
                                ),
                                builder: (context, imgSnapshot) {
                                  final imageUrl = imgSnapshot.data;
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: imageUrl != null
                                            ? NetworkImage(imageUrl)
                                            : const AssetImage(
                                                    "assets/images/doctors4.jpg",
                                                  )
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(width: 12),

                              // 🔹 Data
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s["title"] ?? "Session",
                                      style: const TextStyle(
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
                                        const SizedBox(width: 5),
                                        Text(
                                          formatLocalDate(s["scheduled_at"]),
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorsApp().primaryColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            "${s["duration_minutes"] ?? '?'} min",
                                            style: const TextStyle(
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

Future<List<dynamic>> getParentSessions(String parentId, String status) async {
  final response = await Supabase.instance.client
      .from('sessions')
      .select()
      .eq('parent_id', parentId)
      .eq('status', status)
      .order('scheduled_at', ascending: false);

  print("✅ Parent Sessions Loaded: ${response.length}");
  return response;
}
