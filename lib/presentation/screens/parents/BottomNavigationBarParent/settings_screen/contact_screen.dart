import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:wesal/presentation/widgets/auth/sign_up_in_customTextFields.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),

        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Contact',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(Icons.phone, color: ColorsApp().primaryColor, size: 35),
                ],
              ),
              const SizedBox(height: 15),
              Center(
                child: Image.asset(
                  "assets/images/logo_without_background.png",
                  fit: BoxFit.contain,
                  height: SizeConfig.width * 0.5,
                  width: SizeConfig.width * 0.8,
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.width * 0.04,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            focusNode: contactScreenfullNameFocus,
                            validator: completeDoctor,
                            controller: contactScreenfullName,
                            hintText: 'Full name',
                            icon: Icons.person,
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            focusNode: contactScreenEmailFocus,
                            validator: completeDoctor,
                            controller: contactScreenEmail,
                            hintText: 'Your mail',
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            cursorColor: Colors.black,
                            validator: completeDoctor,
                            controller: contactScreenMessage,
                            maxLines: 3,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: ColorsApp().primaryColor,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 3,
                                ),
                              ),

                              hintText: "Message",
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              if (_isLoading) return;
                              if (_formKey.currentState!.validate()) {
                                if (!mounted) return;
                                setState(() => _isLoading = true);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: ColorsApp().primaryColor,
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
                                        'Sent',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.phone,
                                          size: 35,
                                          color: Colors.green,
                                        ),
                                        SizedBox(height: 5),
                                        Text('Call'),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 22,
                                        right: 15,
                                      ),
                                      child: VerticalDivider(
                                        color: Colors.grey,
                                        width: 20,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.facebook,
                                      size: 40,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(height: 5),
                                    Text('Facebook'),
                                  ],
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: VerticalDivider(
                                    color: Colors.grey,
                                    width: 20,
                                    thickness: 1,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      size: 40,
                                      color: Colors.green,
                                    ),
                                    SizedBox(height: 5),
                                    Text('WhatsApp'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
