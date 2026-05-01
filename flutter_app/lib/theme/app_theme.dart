import 'package:flutter/material.dart';
import 'dart:ui';

const kBg1 = Color(0xFF0A0E27);
const kBg2 = Color(0xFF0D1B4B);
const kAccent1 = Color(0xFF6C63FF);
const kAccent2 = Color(0xFF48CAE4);
const kAccent3 = Color(0xFFFF6584);
const kGlass = Color(0x1AFFFFFF);
const kGlassBorder = Color(0x33FFFFFF);
const kTextPrimary = Colors.white;
const kTextSecondary = Color(0xAAFFFFFF);

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kBg1, kBg2, Color(0xFF1A0533)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80, left: -60,
            child: _Blob(color: kAccent1.withOpacity(0.3), size: 260),
          ),
          Positioned(
            bottom: -100, right: -80,
            child: _Blob(color: kAccent2.withOpacity(0.2), size: 300),
          ),
          Positioned(
            top: 200, right: -40,
            child: _Blob(color: kAccent3.withOpacity(0.15), size: 180),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: const SizedBox(),
        ),
      );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color ?? kGlass,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: kGlassBorder, width: 1.2),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: kTextPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: kTextSecondary),
            prefixIcon: Icon(prefixIcon, color: kTextSecondary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: kGlass,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kGlassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kGlassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kAccent1, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final List<Color> colors;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = const [kAccent1, kAccent2],
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: disabled
              ? [Colors.grey.shade800, Colors.grey.shade700]
              : colors,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: disabled
            ? []
            : [
                BoxShadow(
                  color: colors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.dark(
      primary: kAccent1,
      secondary: kAccent2,
      surface: kBg1,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: kTextPrimary),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: kTextPrimary),
      bodyMedium: TextStyle(color: kTextSecondary),
      bodySmall: TextStyle(color: kTextSecondary),
    ),
  );
}
