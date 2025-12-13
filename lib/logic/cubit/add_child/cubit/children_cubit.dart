import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChildModel {
  final String name;
  final int age;
  final String typeGender;
  final String birthdate;
  final String diagnosis;
  final String hobbies;
  final String? imageUrl;

  ChildModel({
    required this.hobbies,
    required this.diagnosis,
    required this.birthdate,
    required this.name,
    required this.age,
    required this.typeGender,
    this.imageUrl = '',
  });
}

class ChildrenCubit extends Cubit<List<ChildModel>> {
  ChildrenCubit() : super([]);

  addChild(ChildModel child) {
    final updatedList = List<ChildModel>.from(state)..add(child);
    emit(updatedList);
  }

  void removeChild(int index) {
    final updatedList = List<ChildModel>.from(state)..removeAt(index);
    emit(updatedList);
  }

  Future<void> fetchChildrenForCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('children')
          .select(
            'id, name, age, gender, birthdate, diagnosis, hobbies, image_url',
          )
          .eq('parent_id', user.id);

      // حوّل البيانات إلى موديل
      final children = (response as List).map((data) {
        return ChildModel(
          name: data['name'],
          age: data['age'],
          typeGender: data['gender'],
          birthdate: data['birthdate'] ?? '',
          diagnosis: data['diagnosis'] ?? '',
          hobbies: data['hobbies'] ?? '',
          imageUrl: data['image_url'] ?? '',
        );
      }).toList();

      emit(children);
    } catch (e) {
      print('Error fetching children: $e');
    }
  }
}
