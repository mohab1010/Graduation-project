import 'package:wesal/logic/services/colors_app.dart';
import 'package:wesal/logic/services/variables_app.dart';
import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
////////////           selectedGender            /////////////
//////////////////////////////////////////////////////////////
/// Exposes the dropdown as a widget; callers that used the
/// previous dropDown() function can continue to call this.
Widget dropDown() => const _GenderDropdown();

class _GenderDropdown extends StatefulWidget {
  const _GenderDropdown({Key? key}) : super(key: key);

  @override
  State<_GenderDropdown> createState() => _GenderDropdownState();
}

class _GenderDropdownState extends State<_GenderDropdown> {
  String? _localSelectedGender;

  @override
  void initState() {
    super.initState();
    _localSelectedGender = selectedGender;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Gender',
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3789C3)),
        ),
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(Icons.wc, color: ColorsApp().primaryColor),
      ),
      value: _localSelectedGender,
      items: const [
        DropdownMenuItem(value: 'male', child: Text('male')),
        DropdownMenuItem(value: 'female', child: Text('female')),
      ],
      onChanged: (value) {
        setState(() {
          _localSelectedGender = value;
          selectedGender =
              value; // keep the top-level variable in sync if other code uses it
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select gender';
        }
        return null;
      },
    );
  }
}
