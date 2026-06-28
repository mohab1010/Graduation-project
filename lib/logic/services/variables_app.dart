import 'dart:io';
import 'package:wesal/logic/cubit/add_child/cubit/children_cubit.dart';
import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/presentation/screens/auth/sign_in_screen.dart';
import 'package:wesal/presentation/screens/doctors/complete_doctor_profile_screen.dart';
import 'package:wesal/presentation/widgets/on_boarding/on_boarding_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

//////////////////////////////////////////////////////////////
///////            List of onboarding steps            ///////
//////////////////////////////////////////////////////////////
List<OnBoardingScreenWidget> steps = [
  OnBoardingScreenWidget(
    title: "Welcome to Autism Care",
    body:
        "Connecting parents and doctors to provide better support for every child with autism.",
    image: "assets/lottie/Connection.json",
  ),
  OnBoardingScreenWidget(
    title: "Personalized Child Profiles",
    body:
        "Easily add your child’s information—diagnosis, hobbies, and needs—so doctors can tailor their care.",
    image: "assets/lottie/searching_for_profile.json",
  ),
  OnBoardingScreenWidget(
    title: "Seamless Support",
    body:
        "Book sessions, chat, and connect with specialists through secure video and voice calls.",
    image: "assets/lottie/Support.json",
  ),
  OnBoardingScreenWidget(
    title: "AI Autism Chatbot",
    body: "Meet your smart assistant—an AI chatbot designed to understand and support children with autism. Chat, learn, and get instant guidance anytime.",
    image: "assets/lottie/Chat Bot.json",
  ),
];

//////////////////////////////////////////////////////////////
/////         TextEditingController variables          ///////
//////////////////////////////////////////////////////////////
final TextEditingController emailController = TextEditingController();
final TextEditingController passController = TextEditingController();
final TextEditingController confirmPassController = TextEditingController();
final TextEditingController fullNameController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController addChildName = TextEditingController();
final TextEditingController addChildAge = TextEditingController();
final TextEditingController addChildhobbies = TextEditingController();
final TextEditingController addChilddiagnosis = TextEditingController();
final TextEditingController addChildbirthdate = TextEditingController();
final TextEditingController editeProfileName = TextEditingController();
final TextEditingController editProfileEmail = TextEditingController();
final TextEditingController editProfilePhone = TextEditingController();
final TextEditingController specialtyController = TextEditingController();
final TextEditingController qualificationController = TextEditingController();
final TextEditingController bioController = TextEditingController();
final TextEditingController clinicAddressController = TextEditingController();
final TextEditingController doctorsScreenSearch = TextEditingController();
final TextEditingController doctorsDetailsScreenTitle = TextEditingController();
final TextEditingController doctorsDetailsScreenDescription =
    TextEditingController();
final TextEditingController doctorsDetailsScreenScheduledAt =
    TextEditingController();
final TextEditingController doctorsDetailsScreenDurationMinutes =
    TextEditingController();
final TextEditingController addTips = TextEditingController();
final TextEditingController contactScreenfullName = TextEditingController();
final TextEditingController contactScreenEmail = TextEditingController();
final TextEditingController contactScreenMessage = TextEditingController();

//////////////////////////////////////////////////////////////
//////////////         FocusNode            //////////////////
//////////////////////////////////////////////////////////////
final FocusNode emailFocus = FocusNode();
final FocusNode passFocus = FocusNode();
final FocusNode confirmPassFocus = FocusNode();
final FocusNode fullNameFocus = FocusNode();
final FocusNode phoneFocus = FocusNode();
final FocusNode addChildNameFocus = FocusNode();
final FocusNode addChildAgeFocus = FocusNode();
final FocusNode addChildhobbiesFocus = FocusNode();
final FocusNode addChilddiagnosisFocus = FocusNode();
final FocusNode addChildbirthdateFocus = FocusNode();
final FocusNode editProfileNameFocus = FocusNode();
final FocusNode editProfileEmailFocus = FocusNode();
final FocusNode editProfilePhoneFocus = FocusNode();
final FocusNode specialtyControllerFocus = FocusNode();
final FocusNode qualificationControllerFocus = FocusNode();
final FocusNode bioControllerFocus = FocusNode();
final FocusNode clinicAddressControllerFocus = FocusNode();
final FocusNode doctorsScreenSearchFocus = FocusNode();
final FocusNode doctorsDetailsScreenTitleFocus = FocusNode();
final FocusNode doctorsDetailsScreenDescriptionFocus = FocusNode();
final FocusNode doctorsDetailsScreenScheduledAtFocus = FocusNode();
final FocusNode doctorsDetailsScreenDurationMinutesFocus = FocusNode();
final FocusNode contactScreenfullNameFocus = FocusNode();
final FocusNode contactScreenEmailFocus = FocusNode();
final FocusNode addTipsFocus = FocusNode();

//////////////////////////////////////////////////////////////
//////////////         validator            //////////////////
//////////////////////////////////////////////////////////////

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }

  // Regex للتحقق من صيغة الإيميل
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email address';
  }

  return null;
}

///////////////////////////////////////////////////////////////////

String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  return null;
}

String? confirmPasswordValidator(
  String? value,
  TextEditingController passController,
) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  }
  if (value != passController.text) {
    return 'Passwords do not match';
  }
  return null;
}

////////////////////////////////////////////////////////////

String? addChildNameValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the name';
  }
  if (value.length < 3) {
    return 'Name must be at least 3 characters long';
  }
  return null;
}

/////////////////////////////////////////////////////////////

String? addChildAgeValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter the age';
  }

  final age = int.tryParse(value);
  if (age == null) {
    return 'Please enter a valid number';
  }

  if (age < 3) {
    return 'Age must be 3 years or older';
  }

  if (age > 120) {
    return 'Please enter a reasonable age';
  }

  return null;
}

/////////////////////////////////////////////////////////////
String? phoneValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter phone number';
  }
  // رقم الهاتف يجب أن يكون من 10 أرقام
  if (!RegExp(r'^[0-9]{11}$').hasMatch(value)) {
    return 'Please enter a valid 11-digit phone number';
  }
  return null;
}

///////////////////////////////////////////////////////////////

String? completeDoctor(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please fill the field';
  }
  return null;
}

//////////////////////////////////////////////////////////////
/////              List to store children              ///////
//////////////////////////////////////////////////////////////
List<ChildModel> childrenList = [];

//////////////////////////////////////////////////////////////
/////              select image variables              ///////
//////////////////////////////////////////////////////////////
final ImagePicker picker = ImagePicker();
File? selectedImage;

//////////////////////////////////////////////////////////////
/////             select doctor or parent              ///////
//////////////////////////////////////////////////////////////
String userRole = '';
String groqApiKey = '';

void onSignUpSuccess(BuildContext context) {
  if (userRole == 'doctor') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CompleteDoctorProfileScreen(),
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}

//////////////////////////////////////////////////////////////
/////////             selectedGender              ////////////
//////////////////////////////////////////////////////////////
String? selectedGender;

//////////////////////////////////////////////////////////////
/////////            selectedSpecialty            ////////////
//////////////////////////////////////////////////////////////
String? selectedSpecialty;

//////////////////////////////////////////////////////////////
////////////      _infoCard_addChildScreen       /////////////
//////////////////////////////////////////////////////////////
Widget infoCard(IconData icon, String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ),

      Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorsApp().primaryColor.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorsApp().primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : '—',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

//////////////////////////////////////////////////////////////
////////////      duration_minutes_variable      /////////////
//////////////////////////////////////////////////////////////
String duration = doctorsDetailsScreenDurationMinutes.text; // "01:30"
List<String> parts = duration.split(':');
int totalMinutes =
    int.tryParse(duration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

Future<void> pickDateTime(BuildContext context) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );

  if (date == null) return;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (time == null) return;

  final combined = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );

  doctorsDetailsScreenScheduledAt.text = combined.toIso8601String();
}

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);

    String formatted = '';
    if (digits.length <= 2) {
      formatted = digits;
    } else {
      formatted =
          '${digits.substring(0, digits.length - 2)}:${digits.substring(digits.length - 2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

//////////////////////////////////////////////////////////////
////////////           formatLocalDate           /////////////
//////////////////////////////////////////////////////////////
String formatLocalDate(String dateTimeString) {
  try {
    final dt = DateTime.parse(dateTimeString).toLocal();
    return DateFormat('yyyy-MM-dd').format(dt);
  } catch (e) {
    return dateTimeString; // fallback إذا صار خطأ
  }
}

//////////////////////////////////////////////////////////////
////////////           viewDoctorData            /////////////
//////////////////////////////////////////////////////////////
String doctorName = "";
String doctorImage = "";

//////////////////////////////////////////////////////////////
///////////     تحديد الوقت viewDoctorData      /////////////
//////////////////////////////////////////////////////////////
String formatTime(String? dateTimeString) {
  if (dateTimeString == null) return '';

  final dateTime = DateTime.parse(dateTimeString).toUtc();
  final now = DateTime.now().toUtc(); // ✅ مقارنة بنفس التوقيت
  final difference = now.difference(dateTime);

  if (difference.inMinutes <= 0) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    final hours = (difference.inMinutes / 60).floor(); // ✅ أدق
    return '${hours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}
