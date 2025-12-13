import 'dart:io';
import 'package:wesal/logic/services/sign_up_services/save_profile_user_data.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:wesal/logic/services/supabase_services.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_customTextFields.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // Future<String?> uploadImage(File file) async {
  //   try {
  //     final currentUser = Supabase.instance.client.auth.currentUser;
  //     if (currentUser == null) {
  //       debugPrint('No user is currently logged in while uploading the image');
  //       return null;
  //     }
  //     final fileName =
  //         'profile_${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

  //     // رفع الملف
  //     await Supabase.instance.client.storage
  //         .from('profiles_images')
  //         .upload(fileName, file);

  //     // جلب الرابط العام بعد الرفع
  //     final publicUrl = Supabase.instance.client.storage
  //         .from('profiles_images')
  //         .getPublicUrl(fileName);

  //     return publicUrl;
  //   } catch (e) {
  //     debugPrint('Upload error: $e');
  //     return null;
  //   }
  // }

  // Future<void> saveProfilesData() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   String? imageUrl;
  //   final parentUser = Supabase.instance.client.auth.currentUser;
  //   if (parentUser == null) {
  //     debugPrint('No user currently logged in');
  //     return;
  //   }
  //   if (_selectedImage != null) {
  //     imageUrl = await uploadImage(_selectedImage!);
  //   }
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('parent_id', parentUser.id);
  //   print('✅ Parent ID saved55555555555555555555: ${parentUser.id}');
  //   try {
  //     final response = await Supabase.instance.client.from('profiles').insert({
  //       'id': parentUser.id,
  //       'email': emailController.text.trim(),
  //       'full_name': fullNameController.text.trim(),
  //       'phone': phoneController.text.trim(),
  //       'avatar_url': imageUrl ?? '',
  //       'role': userRole,
  //     });

  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('The data has been saved successfully')),
  //     );

  //     return response;
  //   } catch (e) {
  //     debugPrint('Insert error: $e');
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('error: $e')));
  //   }
  // }

  final saveProfileUserData = SaveProfileUserData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.width * 0.035,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: GestureDetector(
                      onTap: () {
                        pickImage();
                      },
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    'Create An Account',
                    style: TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 27,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 200,
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomTextFormField(
                              focusNode: fullNameFocus,
                              validator: addChildNameValidator,
                              controller: fullNameController,
                              hintText: 'Enter Your full name',
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 15),
                            CustomTextFormField(
                              focusNode: emailFocus,
                              validator: emailValidator,
                              controller: emailController,
                              hintText: 'Enter Your Email',
                              icon: Icons.email,
                            ),
                            const SizedBox(height: 15),
                            CustomTextFormField(
                              focusNode: passFocus,
                              validator: passwordValidator,
                              controller: passController,
                              hintText: 'Enter Your Password',
                              icon: Icons.lock,
                              isPassword: true,
                            ),
                            const SizedBox(height: 15),
                            CustomTextFormField(
                              focusNode: confirmPassFocus,
                              validator: (value) => confirmPasswordValidator(
                                value,
                                passController,
                              ),
                              controller: confirmPassController,
                              hintText: 'Confirm Password',
                              icon: Icons.lock,
                              isPassword: true,
                            ),
                            const SizedBox(height: 15),
                            CustomTextFormField(
                              keyboardType: TextInputType.number,
                              focusNode: phoneFocus,
                              validator: phoneValidator,
                              controller: phoneController,
                              hintText: 'Enter Your phone',
                              icon: Icons.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF3789C3)),
                      SizedBox(width: 5),
                      Text('I agree to the ', style: TextStyle(fontSize: 12)),
                      Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3789C3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(' and ', style: TextStyle(fontSize: 12)),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3789C3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async {
                      if (_isLoading) return; // منع النقر المتكرر
                      if (_formKey.currentState!.validate()) {
                        if (!mounted) return;
                        setState(() => _isLoading = true); // تشغيل التحميل
                        try {
                          // 1️⃣ تنفيذ signUp أولاً وانتظاره
                          await SupabaseServices().signUp(
                            context,
                            emailController.text.trim(),
                            passController.text.trim(),
                          );
                          if (!context.mounted) return;
                          // 2️⃣ بعد ما يخلص signUp، ينفذ حفظ البيانات
                          await saveProfileUserData.saveProfilesData(
                            context: context,
                            formKey: _formKey,
                            email: emailController.text.trim(),
                            fullName: fullNameController.text.trim(),
                            phone: phoneController.text.trim(),
                            role: userRole,
                            imageFile: _selectedImage,
                          );
                        } catch (e) {
                          // ❌ في حال حدوث خطأ
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (!mounted) return;
                          setState(
                            () => _isLoading = false,
                          ); // إيقاف التحميل مهما كانت النتيجة
                        }
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
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15),
                  Center(
                    child: Text(
                      'Or sign up with',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.1,
                              ), // لون الظل (مع شفافية)
                              blurRadius: 10, // مدى انتشار الظل
                              spreadRadius: 2, // قوة امتداد الظل
                              offset: Offset(
                                0,
                                5,
                              ), // اتجاه الظل (يمين/يسار, أعلى/أسفل)
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/images/google.png'),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.1,
                              ), // لون الظل (مع شفافية)
                              blurRadius: 10, // مدى انتشار الظل
                              spreadRadius: 2, // قوة امتداد الظل
                              offset: Offset(
                                0,
                                5,
                              ), // اتجاه الظل (يمين/يسار, أعلى/أسفل)
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/images/facebook.png'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Divider(
                    color: Colors.grey[350],
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),

                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignInScreen(),
                            ),
                          );
                          emailController.clear();
                          passController.clear();
                          confirmPassController.clear();
                        },

                        child: Text(
                          " Sign In",
                          style: TextStyle(color: Color(0xFF3789C3)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
