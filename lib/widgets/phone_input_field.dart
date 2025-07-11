import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const PhoneInputField({
    Key? key,
    required this.controller,
    this.validator,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
        _SaudiPhoneFormatter(),
      ],
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF513E35),
      ),
      decoration: InputDecoration(
        labelText: 'رقم الجوال',
        hintText: '0780 XXX XXXX',
        prefixIcon: const Icon(Icons.phone_outlined),
        prefixText: '+964 ',
        prefixStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFF513E35),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF513E35),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// Custom formatter for Saudi phone numbers
class _SaudiPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    if (text.length <= 2) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 5) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}