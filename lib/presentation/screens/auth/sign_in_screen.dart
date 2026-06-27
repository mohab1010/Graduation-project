import 'package:wesal/logic/services/sized_config.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_SocialButton.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_customTextFields.dart';
import 'package:wesal/logic/services/supabase_services.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';

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
                        await SupabaseServices().signIn(context).timeout(
                          const Duration(seconds: 90),
                          onTimeout: () => throw Exception(
                              'Connection timed out. Check your internet and try again.'),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        final msg = e.toString().toLowerCase();
                        String display;
                        if (msg.contains('invalid login credentials') ||
                            msg.contains('invalid_credentials')) {
                          display = 'Wrong email or password. Please try again.';
                        } else if (msg.contains('email') &&
                            msg.contains('confirm')) {
                          display =
                              'Please verify your email first, then try again.';
                        } else if (msg.contains('timed out') ||
                            msg.contains('timeout')) {
                          display =
                              'Connection is slow. Please check your internet and try again.';
                        } else {
                          display = e.toString().replaceAll('Exception: ', '');
                        }
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Login Failed'),
                            content: Text(display),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } finally {
                        if (!mounted) return;
                        setState(() => _isLoading = false);
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
