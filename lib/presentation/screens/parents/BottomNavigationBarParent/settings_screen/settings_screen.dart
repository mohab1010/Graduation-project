import 'package:wesal/logic/cubit/chat_with_ai/cubit/chat_with_ai_cubit.dart';
import 'package:wesal/logic/services/settings_services/settings_services.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/settings_screen/about_screen.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/settings_screen/app_settings_screen.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/settings_screen/change_password_screen.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/settings_screen/contact_screen.dart';
import 'package:share_plus/share_plus.dart' show SharePlus, ShareParams;
import 'package:wesal/presentation/screens/parents/add_child_screen.dart';
import 'package:wesal/presentation/screens/auth/edite_profile.dart';
import 'package:wesal/presentation/screens/parents/chat_with_ai_screen.dart';
import 'package:wesal/presentation/screens/parents/sessions_screen_parent.dart';
import 'package:wesal/presentation/screens/role_selection_screen.dart';
import 'package:wesal/presentation/widgets/profile/buildListTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final profileService = ProfileService();
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {
    profileData = await profileService.getProfile();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
              );
              emailController.clear();
              passController.clear();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // صورة البروفايل
            CircleAvatar(
              radius: 75,
              backgroundColor: Colors.grey[300],
              backgroundImage: (profileData?['avatar_url'] != null &&
                      profileData!['avatar_url'].toString().startsWith('http'))
                  ? NetworkImage(profileData!['avatar_url']) as ImageProvider
                  : const AssetImage(
                      'assets/images/logo_without_background.png',
                    ),
            ),
            const SizedBox(height: 15),
            Text(
              profileData?['full_name'] ?? '',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              profileData?['phone'] ?? '',

              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditeProfile()),
                ).then((value) {
                  if (value == true) {
                    loadProfile(); // 👈 هذا سيعمل refresh تلقائي
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              child: const Text(
                "Edit Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: userRole != 'doctor' ? 350 : 300,
        padding: EdgeInsets.only(top: 10),

        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              userRole != 'doctor'
                  ? Column(
                      children: [
                        buildListTile(
                          icon: Icons.face,
                          title: "children",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddChildScreen(),
                              ),
                            );
                          },
                        ),
                        divider(),
                        buildListTile(
                          icon: Icons.roller_shades_closed_outlined,
                          title: "Chat with AI",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => ChatWithAi(),
                                  child: ChatWithAiScreen(),
                                ),
                              ),
                            );
                          },
                        ),
                        divider(),
                        buildListTile(
                          icon: Icons.calendar_month,
                          title: "My sessions",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MySessionsScreen(),
                              ),
                            );
                          },
                        ),
                        divider(),
                      ],
                    )
                  : SizedBox.shrink(),

              buildListTile(
                icon: Icons.settings,
                title: "Settings",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AppSettingsScreen()),
                  );
                },
              ),
              divider(),
              buildListTile(
                icon: Icons.lock,
                title: "Change password",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                  );
                },
              ),
              divider(),
              buildListTile(
                icon: Icons.card_giftcard_sharp,
                title: "Refer friends",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  SharePlus.instance.share(ShareParams(
                    text: '🌟 Join Wesal App — the best app to support children with autism!\n'
                        'Connect with doctors, get AI support, and manage your child\'s care.\n'
                        'Download now and make a difference! 💙',
                    subject: 'Join Wesal App',
                  ));
                },
              ),
              divider(),
              buildListTile(
                icon: Icons.info,
                title: "About",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                  );
                },
              ),
              divider(),
              buildListTile(
                icon: Icons.phone,
                title: "Contact us",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
