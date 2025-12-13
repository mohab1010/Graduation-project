import 'dart:io';
import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/services/add_child_services/insert_child.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/widgets/parent/add_child/floatingActionButton/dropDown.dart';
import 'package:wesal/presentation/widgets/parent/add_child/floatingActionButton/pickDate.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_customTextFields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingActionButtonWidget extends StatefulWidget {
  const FloatingActionButtonWidget({super.key});

  @override
  State<FloatingActionButtonWidget> createState() =>
      _FloatingActionButtonWidgetState();
}

class _FloatingActionButtonWidgetState
    extends State<FloatingActionButtonWidget> {
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final _childService = ChildService();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );

                        if (pickedFile != null) {
                          setState(() {
                            _selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey[700],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Choose a picture",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      focusNode: addChildNameFocus,
                      validator: addChildNameValidator,
                      controller: addChildName,
                      hintText: 'name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    dropDown(),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      readOnly: true,
                      onTap: () {
                        pickDate(context);
                      },
                      focusNode: addChildbirthdateFocus,
                      validator: completeDoctor,
                      controller: addChildbirthdate,
                      hintText: 'birthdate',
                      icon: Icons.cake,
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      keyboardType: TextInputType.number,
                      focusNode: addChildAgeFocus,
                      validator: addChildAgeValidator,
                      controller: addChildAge,
                      hintText: 'age',
                      icon: Icons.cake, // أيقونة مناسبة للعمر
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      focusNode: addChilddiagnosisFocus,
                      validator: completeDoctor,
                      controller: addChilddiagnosis,
                      hintText: 'diagnosis',
                      icon: Icons.medical_information,
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      focusNode: addChildhobbiesFocus,
                      validator: completeDoctor,
                      controller: addChildhobbies,
                      hintText: 'hobbies',
                      icon: Icons.interests,
                    ),

                    const SizedBox(height: 35),
                    GestureDetector(
                      onTap: () async {
                        final result = await _childService.saveChildData(
                          name: addChildName.text,
                          gender: selectedGender!,
                          birthdate: addChildbirthdate.text,
                          age: int.parse(addChildAge.text),
                          diagnosis: addChilddiagnosis.text,
                          hobbies: addChildhobbies.text,
                          imageFile: _selectedImage,
                        );

                        if (result == null) return;

                        final uploadedImageUrl = result['imageUrl'];
                        final childId =
                            result['id']; // ← id المولّد من Supabase

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('child_id', childId);

                        print('✅ Child ID from Supabase: $childId');

                        if (_formKey.currentState!.validate()) {
                          await context.read<ChildrenCubit>().addChild(
                            ChildModel(
                              name: addChildName.text,
                              age: int.parse(addChildAge.text),
                              typeGender: selectedGender!,
                              birthdate: addChildbirthdate.text,
                              diagnosis: addChilddiagnosis.text,
                              hobbies: addChildhobbies.text,
                              imageUrl: uploadedImageUrl ?? '',
                            ),
                          );

                          Navigator.pop(context);
                        }

                        addChildName.clear();
                        addChildAge.clear();
                        addChildhobbies.clear();
                        addChilddiagnosis.clear();
                        addChildbirthdate.clear();
                        _selectedImage = null;
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
                            'Add',
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
          ),
        );
      },
      backgroundColor: const Color(0xFF3789C3),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
