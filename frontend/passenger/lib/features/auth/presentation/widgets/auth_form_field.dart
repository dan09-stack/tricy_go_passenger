import 'package:flutter/material.dart';
import 'package:tricygo_passenger/core/theme.dart';

class AuthFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final TextInputType inputType;
  final bool isRequired;

  const AuthFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.inputType = TextInputType.text,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.white60,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.darkGray,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white38, size: 20),
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.white12),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
