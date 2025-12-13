import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_SocialButton.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_customTextFields.dart';
import 'package:wesal/logic/services/supabase_services.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/auth/sign_up_screen.dart';
import 'package:wesal/presentation/widgets/doctors/bottom_navigation_bar_doctor.dart';
import 'package:wesal/presentation/widgets/parent/bottom_navigation_bar_parent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.asset(
                      'assets/images/logo_without_background.png',
                      height: 175,
                      width: 175,
                    ),
                  ),
                  Text(
                    'Sign In Your Account',
                    style: TextStyle(
                      letterSpacing: -0.5,
                      fontSize: 27,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextFormField(
                    focusNode: emailFocus,
                    validator: emailValidator,
                    controller: emailController,
                    hintText: 'Enter Your Email',
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 20),
                  CustomTextFormField(
                    focusNode: passFocus,
                    validator: passwordValidator,
                    controller: passController,
                    hintText: 'Enter Your Password',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF3789C3)),
                      SizedBox(width: 5),
                      Text('Remmember me', style: TextStyle(fontSize: 13)),
                      Spacer(),
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 13,
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
                      setState(() => _isLoading = true); // تشغيل التحميل

                      try {
                        await SupabaseServices().signIn(context);

                        final user = Supabase.instance.client.auth.currentUser;
                        if (user != null) {
                          // 👇 استدعاء الجلب بعد تسجيل الدخول
                          await context
                              .read<ChildrenCubit>()
                              .fetchChildrenForCurrentUser();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('parent_id', user.id);
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => userRole == 'doctor'
                          //         ? MainBottomNavDoctor()
                          //         : MainBottomNavParent(),
                          //   ),
                          // );
                        }
                      } catch (e) {
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
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // GestureDetector(
                  //   onTap: () async {
                  //     await SupabaseServices().signIn(context);

                  //     final user = Supabase.instance.client.auth.currentUser;
                  //     if (user != null) {
                  //       // 👇 استدعاء الجلب بعد تسجيل الدخول
                  //       await context
                  //           .read<ChildrenCubit>()
                  //           .fetchChildrenForCurrentUser();

                  //       final currentUser =
                  //           await Supabase.instance.client.auth.currentUser;
                  //       if (currentUser != null) {
                  //         final prefs = await SharedPreferences.getInstance();
                  //         await prefs.setString('parent_id', currentUser.id);
                  //       }

                  //       // 👇 بعدين روح على صفحة AddChild
                  //       Navigator.pushReplacement(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => userRole == 'doctor'
                  //               ? HomeScreen()
                  //               : MainBottomNav(),
                  //         ),
                  //       );
                  //     }
                  //   },
                  //   child: Container(
                  //     width: double.infinity,
                  //     height: 50,
                  //     decoration: BoxDecoration(
                  //       color: Color(0xFF3789C3),
                  //       borderRadius: BorderRadius.circular(25),
                  //     ),
                  //     child: Center(
                  //       child: Text(
                  //         'Sign In',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Or sign in with',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SocialButton(
                        imagePath: 'assets/images/google.png',
                        onTap: () {
                          print("Google tapped");
                        },
                      ),

                      SocialButton(
                        imagePath: 'assets/images/facebook.png',
                        onTap: () {
                          print("Facebook tapped");
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                        "Don't have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                          emailController.clear();
                          passController.clear();
                        },
                        child: Text(
                          " Sign Up",
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
  }
}
