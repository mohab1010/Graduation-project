import 'dart:developer';

import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/error/supabase_exceptions.dart';
import 'package:wesal/logic/services/di/dependancy_injection.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/logic/services/zego_services/zego_services.dart';
import 'package:wesal/presentation/screens/auth/sign_up_screen.dart';
import 'package:wesal/presentation/widgets/doctors/bottom_navigation_bar_doctor.dart';
import 'package:wesal/presentation/widgets/parent/bottom_navigation_bar_parent.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServices {
  //////////////////////////////////////////////////////////////
  /////////             Future of signup              //////////
  //////////////////////////////////////////////////////////////
  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> streamDataWithSpecificId({
    required String tableName,
    required String id,
    String? primaryKey,
  }) async* {
    final supabase = Supabase.instance.client;
    try {
      yield* supabase
          .from(tableName)
          .stream(primaryKey: ['id'])
          .eq(primaryKey ?? 'id', id)
          .handleError((error) {
            throw SupabaseExceptions(
              errorMessage: 'Error while streaming data: $error',
            );
          })
          .map((data) {
            if (data.isEmpty) {
              return [];
            }
            return data;
          });
    } catch (e) {
      throw SupabaseExceptions(
        errorMessage: 'Exception caught in streamData: $e',
      );
    }
  }

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
  ) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: emailController.text,
      password: passController.text,
      // emailRedirectTo: 'autism://login-callback',
    );

    if (!context.mounted) return;
    if (response.user != null) {
      onSignUpSuccess(context);

      print('Sign up successful');
    } else {
      print('Handle error');
    }
  }

  //////////////////////////////////////////////////////////////
  /////////             Future of signin              //////////
  //////////////////////////////////////////////////////////////
  Future<void> signIn(BuildContext context) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text,
        password: passController.text,
      );

      if (response.user != null) {
        log("Wait for token");
        final firebaseMessaging = getIt<FirebaseMessaging>();
        final token = await firebaseMessaging.getToken();
        // final response = await Supabase.instance.client
        //     .from("profiles")
        //     .select()
        //     .eq("id", Supabase.instance.client.auth.currentUser!.id)
        //     .single();
        final response = await Supabase.instance.client
            .from("profiles")
            .select('full_name, user_zego_id, role, tokens')
            .eq("id", Supabase.instance.client.auth.currentUser!.id)
            .single();
        ////////////////////////////////////////////
        String userRoleSignIn = response["role"]; // ✅ المهم

        if (userRole != userRoleSignIn) {
          await Supabase.instance.client.auth.signOut();

          AwesomeDialog(
            context: context,
            dialogType: DialogType.warning,
            animType: AnimType.scale,
            dismissOnTouchOutside: false,
            title: "Wrong Account Type",
            desc: userRole == 'doctor'
                ? "This account is not registered as a Doctor.\nPlease login with a Doctor account."
                : "This account is not registered as a Parent.\nPlease login with a Parent account.",
            btnOkText: "OK",
            btnOkOnPress: () {},
          )..show();

          return; // ⛔ وقف تسجيل الدخول فورًا
        }
        ///////////////////////////////////////////////
        String userName = response["full_name"];
        String userZegoId = (response["user_zego_id"]).toString();
        await ZegoServices.onUserLogin(userId: userZegoId, userName: userName);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', userRoleSignIn);

        final currentTokens = response["tokens"] ?? [];
        if (!currentTokens.contains(token)) {
          final updatedTokens = [...currentTokens, token];
          await supabase
              .from("profiles")
              .update({"tokens": updatedTokens})
              .eq("id", Supabase.instance.client.auth.currentUser!.id);
        }
        log("Done");
        print('Login successful');
        if (userRoleSignIn == 'doctor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainBottomNavDoctor()),
          );
        } else if (userRoleSignIn == 'parent') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainBottomNavParent()),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Unknown user role")));
        }
      } else {
        // إذا ما لقى الحساب
        _showSignUpDialog(context);
      }
    } catch (e) {
      if (e.toString().contains("Invalid login credentials")) {
        _showSignUpDialog(context);
      } else {
        // AwesomeDialog? dialog;
        //
        // dialog = AwesomeDialog(
        //   context: context,
        //   dismissOnTouchOutside: false,
        //   dialogType: DialogType.warning,
        //   animType: AnimType.bottomSlide,
        //   btnOkOnPress: () {},
        //   desc: "Please verify your account before logging in",
        // )..show();
        // dialog;
        print('Error: $e');
      }
    }
  }

  //////////////////////////////////////////////////////////////
  /////////           _showSignUpDialog               //////////
  //////////////////////////////////////////////////////////////
  void _showSignUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("Account not found"),
          // contentTextStyle: TextStyle(

          // ),
          content: Text(
            "You don\'t have an account yet. Do you want to sign up?",
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red),
              ),
              onPressed: () {
                Navigator.pop(ctx); // إغلاق الديالوج
              },
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green),
              ),
              onPressed: () {
                Navigator.pop(ctx); // إغلاق الديالوج
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
                emailController.clear();
                passController.clear();
              },
              child: Text("Sign Up", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  //////////////////////////////////////////////////////////////
  /////////          Future of deleteChild            //////////
  //////////////////////////////////////////////////////////////
  Future<void> deleteChild(String childId, BuildContext context) async {
    try {
      final response = await Supabase.instance.client
          .from('children')
          .delete()
          .eq('id', childId); // شرط الحذف حسب id الطفل

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child deleted successfully')),
        );

        // ✅ إعادة تحميل البيانات بعد الحذف
        await context.read<ChildrenCubit>().fetchChildrenForCurrentUser();
      }
    } catch (e) {
      debugPrint('Delete error: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting child: $e')));
    }
  }
}
