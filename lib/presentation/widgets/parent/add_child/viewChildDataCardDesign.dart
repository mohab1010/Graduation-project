import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
//////////      viewChildData_addChildScreen       ///////////
//////////////////////////////////////////////////////////////
Future<dynamic> viewChildData(BuildContext context, ChildModel child) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // صورة الطفل
                Center(
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.deepOrange.withOpacity(0.1),
                    backgroundImage:
                        (child.imageUrl != null && child.imageUrl!.isNotEmpty)
                        ? NetworkImage(child.imageUrl!)
                        : null,
                    child: (child.imageUrl == null || child.imageUrl!.isEmpty)
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.orange,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: const Text(
                    'Child Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),

                infoCard(Icons.person, child.name, 'name'),
                infoCard(Icons.wc, child.typeGender, 'Gender'),
                infoCard(Icons.cake, child.birthdate, 'birthdate'),
                infoCard(Icons.cake, '${child.age}', 'age'),
                infoCard(
                  Icons.medical_information,
                  child.diagnosis,
                  'diagnosis',
                ),
                infoCard(Icons.interests, child.hobbies, 'hobbies'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
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
                        'Close',
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
          ),
        ),
      );
    },
  );
}
