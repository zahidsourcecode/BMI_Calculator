import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.width,
    this.height,
  });

  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: width,
        height: height,
        padding: height == null ? EdgeInsets.symmetric(vertical: 16.0) : null,
        decoration: BoxDecoration(
          color: enabled ? Color(0xFF1B5E7E) : Color(0xFF808080),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: height != null ? 22 : 20.0,
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.white : Color(0xFFBEBEBE),
            ),
          ),
        ),
      ),
    );
  }
}
