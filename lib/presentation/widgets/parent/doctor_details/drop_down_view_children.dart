import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DropDownViewChildren extends StatefulWidget {
  const DropDownViewChildren({super.key});

  @override
  State<DropDownViewChildren> createState() => _DropDownViewChildrenState();
}

class _DropDownViewChildrenState extends State<DropDownViewChildren> {
  String? selectedChild;

  Future<String?> getChildIdByName(String childName) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    final response = await Supabase.instance.client
        .from('children')
        .select('id')
        .eq('name', childName)
        .eq('parent_id', user.id)
        .single();

    return response['id'];
  }

  @override
  void initState() {
    super.initState();
    context.read<ChildrenCubit>().fetchChildrenForCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildrenCubit, List<ChildModel>>(
      builder: (context, children) {
        if (children.isEmpty) {
          return const Text('No children found');
        }

        return DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Select Child',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
                  Icon(Icons.child_care, color: ColorsApp().primaryColor),
                  const SizedBox(width: 8),
                  Container(height: 24, width: 1, color: Colors.grey),
                ],
              ),
            ),
          ),
          value: selectedChild,
          items: children
              .map(
                (child) => DropdownMenuItem(
                  value: child.name,
                  child: Text(child.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) async {
            setState(() => selectedChild = value);

            if (value != null) {
              String? childId = await getChildIdByName(value);

              if (childId != null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('child_id', childId);

                print("✅ Selected Child ID Saved: $childId");
              }
            }
          },
        );
      },
    );
  }
}
