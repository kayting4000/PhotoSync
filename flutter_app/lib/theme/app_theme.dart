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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kBg1, kBg2, Color(0xFF1A0533)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -80, left: -60,
                child: _Blob(color: kAccent1.withOpacity(0.3), size: constraints.maxWidth * 0.65),
              ),
              Positioned(
                bottom: -100, right: -80,
                child: _Blob(color: kAccent2.withOpacity(0.2), size: constraints.maxWidth * 0.75),
              ),
              Positioned(
                top: constraints.maxHeight * 0.3, right: -40,
                child: _Blob(color: kAccent3.withOpacity(0.15), size: constraints.maxWidth * 0.45),
              ),
              child,
            ],
          ),
        );
      },
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

// ── AI Assistant Bubble ──────────────────────────────────────────────────────
class AIAssistantBubble extends StatefulWidget {
  const AIAssistantBubble({super.key});

  @override
  State<AIAssistantBubble> createState() => _AIAssistantBubbleState();
}

class _AIAssistantBubbleState extends State<AIAssistantBubble>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  final _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messages.add({
        'role': 'ai',
        'text': _getAutoReply(text),
      });
    });
    _controller.clear();
  }

  String _getAutoReply(String input) {
    final q = input.toLowerCase();
    if (q.contains('student')) return 'Go to Manage Students to add or view students.';
    if (q.contains('subject')) return 'Go to Manage Subjects to create subjects.';
    if (q.contains('scan') || q.contains('paper')) return 'Use the Scanner to upload and analyze test papers.';
    if (q.contains('grade') || q.contains('gpa')) return 'Check the Grades screen to view GPA and results.';
    if (q.contains('email')) return 'Use Send Email Reports to notify students.';
    if (q.contains('creator') || q.contains('who made')) return 'EduScan was created by Habibun-najal K. Kayting. Email: kayting4k@gmail.com';
    return 'Hi! I can help you navigate EduScan. Ask me about students, subjects, scanning, grades, or emails.';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isOpen)
          ScaleTransition(
            scale: _scaleAnim,
            alignment: Alignment.bottomRight,
            child: Container(
              width: 300,
              height: 380,
              margin: const EdgeInsets.only(bottom: 72, right: 4),
              child: GlassCard(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [kAccent1, kAccent2]),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('EduScan AI',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          GestureDetector(
                            onTap: _toggle,
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                    // Messages
                    Expanded(
                      child: _messages.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Hi! Ask me anything about EduScan 👋',
                                  style: TextStyle(
                                      color: kTextSecondary, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _messages.length,
                              itemBuilder: (context, i) {
                                final msg = _messages[i];
                                final isUser = msg['role'] == 'user';
                                return Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    constraints: const BoxConstraints(
                                        maxWidth: 220),
                                    decoration: BoxDecoration(
                                      gradient: isUser
                                          ? const LinearGradient(
                                              colors: [kAccent1, kAccent2])
                                          : null,
                                      color: isUser ? null : kGlass,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isUser
                                          ? null
                                          : Border.all(
                                              color: kGlassBorder),
                                    ),
                                    child: Text(
                                      msg['text']!,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Input
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                  color: kTextPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Ask something...',
                                hintStyle: const TextStyle(
                                    color: kTextSecondary, fontSize: 12),
                                filled: true,
                                fillColor: kGlass,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: kGlassBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: kGlassBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: kAccent1, width: 1.5),
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [kAccent1, kAccent2]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Bubble button
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kAccent1.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
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
