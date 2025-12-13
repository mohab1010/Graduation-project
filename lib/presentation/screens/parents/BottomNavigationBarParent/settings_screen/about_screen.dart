import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/sized_config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Icon(Icons.info, color: ColorsApp().primaryColor, size: 35),
                ],
              ),
              const SizedBox(height: 20),

              /// --- Logo ---
              Center(
                child: Image.asset(
                  "assets/images/logo_without_background.png",
                  fit: BoxFit.contain,
                  height: SizeConfig.width * 0.5,
                  width: SizeConfig.width * 0.8,
                ),
              ),
              const SizedBox(height: 20),

              /// --- Content ---
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.width * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// --- Title ---
                        Text(
                          "About Autism",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ColorsApp().primaryColor,
                          ),
                          textAlign: TextAlign.start,
                        ),

                        const SizedBox(height: 5),

                        /// --- App Description ---
                        Text(
                          """
This app is designed to support children with Autism Spectrum Disorder (ASD) and their families by providing a safe, supportive, and easy-to-use environment.

Our mission is to help parents better understand their children, track their development, and connect with qualified specialists who truly care. We believe that every child is unique, and with the right guidance and support, they can grow, learn, and thrive.

Through the app, you can:
• Create and manage child profiles
• Track development and daily activities
• Receive professional guidance and advice
• Book appointments with autism specialists
• Access trusted resources and support

We aim to build a bridge between families and professionals, making autism care more accessible, organized, and compassionate.
""",
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// --- Contact Section ---
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
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
                                  Icon(
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
                                  Icon(
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

                        const SizedBox(height: 30),
                      ],
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
