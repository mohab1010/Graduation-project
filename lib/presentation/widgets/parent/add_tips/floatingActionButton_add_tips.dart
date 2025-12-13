import 'dart:io';

import 'package:wesal/logic/services/add_tips_services/add_tips_services.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_customTextFields.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FloatingactionbuttonAddTips extends StatefulWidget {
  final VoidCallback onTipAdded;
  const FloatingactionbuttonAddTips({super.key, required this.onTipAdded});

  @override
  State<FloatingactionbuttonAddTips> createState() =>
      _FloatingactionbuttonAddTipsState();
}

class _FloatingactionbuttonAddTipsState
    extends State<FloatingactionbuttonAddTips> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(15),
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
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[350],
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
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
                    SizedBox(height: 15),
                    CustomTextFormField(
                      maxLines: 10,
                      focusNode: addTipsFocus,
                      validator: completeDoctor,
                      controller: addTips,
                      hintText: 'Tip Content',
                      icon: Icons.lightbulb,
                    ),
                    SizedBox(height: 18),
                    GestureDetector(
                      onTap: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final doctorId =
                            Supabase.instance.client.auth.currentUser?.id;
                        if (doctorId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("User not logged in")),
                          );
                          return;
                        }

                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        // Pass the selected File directly to insertTip; insertTip will handle uploading.
                        final success = await TipService().insertTip(
                          doctorId: doctorId,
                          tipContent: addTips.text,
                          imageFile: _selectedImage,
                        );

                        Navigator.pop(context, true); // Close Loading Dialog

                        if (success == true) {
                          Navigator.pop(
                            context,
                            true,
                          ); // ✅ Return true to refresh page
                          addTips.clear();
                          _selectedImage = null;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Tip added successfully ✅")),
                          );
                          widget.onTipAdded();
                        }
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
        ).then((value) {
          if (value == true) {
            // ✅ Refresh TipsScreen after adding
            (context as Element).markNeedsBuild();
          }
        });
      },
      backgroundColor: const Color(0xFF3789C3),
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}
