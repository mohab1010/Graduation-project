import 'dart:developer';

import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/error/supabase_exceptions.dart';
import 'package:wesal/logic/services/di/dependancy_injection.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/logic/services/zego_services/zego_services.dart';
import 'package:wesal/presentation/screens/auth/sign_up_screen.dart';
import 'package:wesal/presentation/widgets/doctors/bottom_navigation_bar_doctor.dart';
import 'package:wesal/presentation/widgets/parent/bottom_navigation_bar_parent.dart';
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
      email: email,
      password: password,
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
    // 1. authenticate
    final authResponse = await Supabase.instance.client.auth
        .signInWithPassword(
          email: emailController.text.trim(),
          password: passController.text.trim(),
        )
        .timeout(const Duration(seconds: 60));

    if (authResponse.user == null) {
      if (context.mounted) _showSignUpDialog(context);
      return;
    }

    // 2. get role only
    final profile = await Supabase.instance.client
        .from("profiles")
        .select('full_name, user_zego_id, role')
        .eq("id", authResponse.user!.id)
        .single()
        .timeout(const Duration(seconds: 60));

    final String role = profile["role"] ?? '';
    final String userName = profile["full_name"] ?? "User";
    final String zegoId =
        profile["user_zego_id"]?.toString() ?? authResponse.user!.id;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
    userRole = role;

    // 3. navigate
    if (!context.mounted) return;
    if (role == 'doctor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainBottomNavDoctor()),
      );
    } else if (role == 'parent') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainBottomNavParent()),
      );
    } else {
      throw Exception('Unknown role: $role');
    }

    // 4. background: firebase token + zego (don't block login)
    Future(() async {
      try {
        final token = await getIt<FirebaseMessaging>()
            .getToken()
            .timeout(const Duration(seconds: 10), onTimeout: () => null);
        if (token != null) {
          final current = await supabase
              .from("profiles")
              .select('tokens')
              .eq("id", authResponse.user!.id)
              .single();
          final List tokens = current["tokens"] ?? [];
          if (!tokens.contains(token)) {
            await supabase
                .from("profiles")
                .update({"tokens": [...tokens, token]})
                .eq("id", authResponse.user!.id);
          }
        }
      } catch (e) {
        log("Token update error: $e");
      }
      try {
        await ZegoServices.onUserLogin(userId: zegoId, userName: userName);
      } catch (e) {
        log("Zego init error: $e");
      }
    });
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
      await Supabase.instance.client
          .from('children')
          .delete()
          .eq('id', childId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child deleted successfully')),
      );
      await context.read<ChildrenCubit>().fetchChildrenForCurrentUser();
    } catch (e) {
      debugPrint('Delete error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting child: $e')),
      );
    }
  }
}
