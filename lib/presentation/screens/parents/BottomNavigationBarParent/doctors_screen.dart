import 'package:wesal/logic/services/doctors_screen/save_filter_doctors.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/parents/doctor_details_screen.dart';
import 'package:wesal/presentation/widgets/parent/doctors_screen/card_gridView_widget.dart';
import 'package:wesal/presentation/widgets/parent/doctors_screen/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController doctorsScreenSearch = TextEditingController();
  final DoctorService _doctorService = DoctorService();

  List<dynamic> doctors = [];
  List<dynamic> filteredDoctors = [];
  String? selectedSpecialtyLabel;
  bool isLoading = true;
  List<Map<String, dynamic>> allTips = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    loadUserData();
  }

  Future<void> _loadDoctors() async {
    setState(() => isLoading = true);
    final doctorList = await _doctorService.loadDoctors();
    setState(() {
      doctors = doctorList;
      filteredDoctors = doctorList;
      isLoading = false;
    });
  }

  Future<void> _filterDoctors(String specialty) async {
    setState(() => isLoading = true);
    final filtered = await _doctorService.filterDoctors(specialty);
    setState(() {
      filteredDoctors = filtered;
      selectedSpecialtyLabel = specialty;
      isLoading = false;
    });
  }

  void _showFilterSheet() async {
    final selected = await showFilterBottomSheet(context);
    if (selected != null) {
      await _filterDoctors(selected);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      selectedSpecialtyLabel = null;
      filteredDoctors = _doctorService.searchDoctors(doctors, value);
    });
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

  //////////////////////////////////
  Future<void> loadDoctorTips() async {
    try {
      final response = await Supabase.instance.client
          .from('tips')
          .select('''
          tip_content,
          image_url,
          created_at,
          profiles:doctor_id(full_name, avatar_url)
        ''')
          .order('created_at', ascending: false);

      setState(() {
        allTips = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("❌ Error loading doctor tips: $e");
    }
  }

  Future<void> loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch role
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = profile['role'];

      if (role == 'doctor') {
        await loadDoctorName();
      } else if (role == 'parent') {
        await loadDoctorTips();
      }
    } catch (e) {
      print("❌ Error loading user role: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],

        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Doctors',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(Icons.medical_services, color: ColorsApp().primaryColor),
                ],
              ),
              const SizedBox(height: 15),

              // 🔹 حقل البحث
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: doctorsScreenSearch,
                      cursorColor: ColorsApp().primaryColor,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        hintText: 'Search for doctors',
                        prefixIcon: Icon(
                          Icons.search,
                          color: ColorsApp().primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: ColorsApp().primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 العنوان
              Text(
                selectedSpecialtyLabel == null
                    ? 'All Doctors'
                    : '${selectedSpecialtyLabel!} Doctors',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                softWrap: false,
              ),

              const SizedBox(height: 10),

              // 🔹 عرض البيانات
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredDoctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 0.85,
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorDetailsScreen(doctor: doctor),
                                ),
                              );
                            },
                            child: CardGridViewWidget(
                              name:
                                  doctor['profiles']?['full_name'] ?? 'Unknown',
                              specialty: doctor['specialty'] ?? '',
                              imageUrl: doctor['profiles']?['avatar_url'],
                              doctor: doctor,
                            ),
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
