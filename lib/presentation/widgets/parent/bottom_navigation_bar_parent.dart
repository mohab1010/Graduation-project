import 'package:wesal/logic/cubit/my_chats/cubit/my_chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';

import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/chats_screen.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/doctors_screen.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/games_screen.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/tips_screen.dart';
import 'package:wesal/presentation/screens/parents/BottomNavigationBarParent/settings_screen/settings_screen.dart';
import 'package:wesal/logic/services/colors_app.dart';

class MainBottomNavParent extends StatefulWidget {
  const MainBottomNavParent({super.key});

  @override
  State<MainBottomNavParent> createState() => _MainBottomNavParentState();
}

class _MainBottomNavParentState extends State<MainBottomNavParent>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const TipsScreen(),
    const DoctorsScreen(),
    BlocProvider(
      create: (context) => MyChatsCubit(),
      child: const ChatsScreen(),
    ),
    const KidsGamesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: MotionTabBar(
        initialSelectedTab: "Doctors",
        labels: const ["Tips", "Doctors", "Chats", "Games", "Settings"],
        icons: const [
          Icons.lightbulb_outline,
          Icons.local_hospital_outlined,
          Icons.chat,
          Icons.videogame_asset_outlined,
          Icons.settings_outlined,
        ],
        tabIconColor: Colors.grey,
        tabIconSelectedColor: Colors.white,
        tabSelectedColor: ColorsApp().primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTabItemSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
