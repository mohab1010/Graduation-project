import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/presentation/widgets/parent/add_child/borderRaduisWidget.dart';
import 'package:wesal/presentation/widgets/parent/add_child/viewChildDataCardDesign.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/presentation/widgets/parent/add_child/floatingActionButton/floatingActionButton.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  int chilCount = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        context.read<ChildrenCubit>().fetchChildrenForCurrentUser();
      } else {
        // في حال المستخدم مو مسجل دخول
        print('No user logged in yet');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChildrenCubit, List<ChildModel>>(
      listener: (context, state) {
        setState(() {
          chilCount = state.length;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0, // لإزالة الظل
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(Icons.search),
            ),
          ],
        ),

        extendBodyBehindAppBar: true, // حتى يسمح للشكل يطلع لفوق
        backgroundColor: Color.fromARGB(255, 167, 194, 224),
        floatingActionButton: FloatingActionButtonWidget(),

        body: Stack(
          children: [
            /// الشكل البيضوي في الأعلى
            Positioned(
              top: -100, // كم يطلع لفوق (غير الرقم حسب ما بدك)
              left: 0,
              right: 0,
              child: Container(
                height: 300, // حجم الشكل
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(150), // منحني من الأسفل فقط
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/images/logo_without_background.png',
                      height: 90,
                      width: 90,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Children',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$chilCount child',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            /// المحتوى الأساسي تحت الشكل
            BlocBuilder<ChildrenCubit, List<ChildModel>>(
              builder: (context, state) {
                if (state.isEmpty) {
                  return const Center(child: Text('No children added yet'));
                }
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 220,
                  ), // علشان المحتوى ينزل تحت الشكل البيضوي
                  child: ListView.builder(
                    itemCount: chilCount = state.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final child = state[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            viewChildData(context, child);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Column(
                              children: [
                                ClipPath(
                                  clipper: CylinderClipper(curveHeight: 25),
                                  child: Container(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    height: 180,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: (child.imageUrl != null &&
                                              child.imageUrl!.isNotEmpty)
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                child.imageUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(60),
                                        topRight: Radius.circular(60),
                                        bottomLeft: Radius.circular(60),
                                        bottomRight: Radius.circular(60),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            child.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.medical_information,
                                                size: 16,
                                                color: ColorsApp().primaryColor,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                child.diagnosis,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<ChildrenCubit>()
                                            .removeChild(index);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Deleted successfully',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
