import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  static const Color primary = Color(0xFF3789C3);

  bool _notifications = true;
  bool _emailAlerts = true;
  bool _sessionReminders = true;
  bool _newMessages = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('setting_notifications') ?? true;
      _emailAlerts = prefs.getBool('setting_emailAlerts') ?? true;
      _sessionReminders = prefs.getBool('setting_sessionReminders') ?? true;
      _newMessages = prefs.getBool('setting_newMessages') ?? true;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _sectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildCard([
              _buildToggle(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive all app notifications',
                value: _notifications,
                onChanged: (v) {
                  setState(() => _notifications = v);
                  _savePref('setting_notifications', v);
                },
              ),
              _divider(),
              _buildToggle(
                icon: Icons.email_outlined,
                title: 'Email Alerts',
                subtitle: 'Get updates via email',
                value: _emailAlerts,
                onChanged: (v) {
                  setState(() => _emailAlerts = v);
                  _savePref('setting_emailAlerts', v);
                },
              ),
              _divider(),
              _buildToggle(
                icon: Icons.calendar_today_outlined,
                title: 'Session Reminders',
                subtitle: 'Remind me before sessions',
                value: _sessionReminders,
                onChanged: (v) {
                  setState(() => _sessionReminders = v);
                  _savePref('setting_sessionReminders', v);
                },
              ),
              _divider(),
              _buildToggle(
                icon: Icons.message_outlined,
                title: 'New Messages',
                subtitle: 'Notify on new chat messages',
                value: _newMessages,
                onChanged: (v) {
                  setState(() => _newMessages = v);
                  _savePref('setting_newMessages', v);
                },
              ),
            ]),
            const SizedBox(height: 24),
            _sectionTitle('App Info'),
            const SizedBox(height: 12),
            _buildCard([
              _buildInfo(icon: Icons.info_outline, title: 'Version', value: '1.0.0'),
              _divider(),
              _buildInfo(icon: Icons.language, title: 'Language', value: 'English'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch(activeColor: primary, value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildInfo({required IconData icon, required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);
}
