import 'package:flutter/material.dart';
import 'package:wesal/logic/services/colors_app.dart';

Future<String?> showFilterBottomSheet(BuildContext context) async {
  String? selectedSpecialty;
  final specialties = [
    "Pediatric Neurologist",
    "Child Psychiatrist",
    "Developmental and Behavioral Pediatrician",
    "Pediatrician",
    "Speech and Language Therapist",
    "Occupational Therapist",
    "Applied Behavior Analyst (ABA Therapist)",
    "Clinical Psychologist",
    "Physiotherapist",
    "Special Education Specialist",
    "Music Therapist",
    "Art Therapist",
    "Social Worker",
    "Nutritionist",
    "Geneticist",
    "Occupational Health Specialist",
  ];

  return await showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter by Specialty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Select Specialty',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF3789C3)),
                    ),
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: ColorsApp().primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Container(height: 24, width: 1, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  value: selectedSpecialty,
                  items: specialties
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => selectedSpecialty = value),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, selectedSpecialty);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF3789C3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
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
              ],
            ),
          );
        },
      );
    },
  );
}
