import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Dark Mode Colors ───────────────────────────────────────────────────
const dBg1 = Color(0xFF0A0E27);
const dBg2 = Color(0xFF0D1B4B);
const dAccent1 = Color(0xFF6C63FF);
const dAccent2 = Color(0xFF48CAE4);
const dAccent3 = Color(0xFFFF6584);
const dGlass = Color(0x1AFFFFFF);
const dGlassBorder = Color(0x33FFFFFF);
const dTextPrimary = Colors.white;
const dTextSecondary = Color(0xAAFFFFFF);

// ─── Light Mode Colors (Neumorphic Sky Blue Theme) ────────────────────
// Neumorphic base background (light sky blue)
const lBgBase = Color(0xFFE0F0FF);    // Soft light blue background
const lBgStart = Color(0xFFB8D8F0);   // Slightly darker for shadows
const lBgMid = Color(0xFFE0F0FF);     // Medium base
const lBgEnd = Color(0xFFF5FBFF);     // Lighter for highlights
const lSurface = Color(0xFFE0F0FF);   // Neumorphic surface color
const lAccent1 = Color(0xFF6C63FF);
const lAccent2 = Color(0xFF48CAE4);
const lAccent3 = Color(0xFFFF6584);
// Neumorphic glass/container colors
const lGlass = Color(0xFFE0F0FF);     // Neumorphic surface base
const lGlassBorder = Colors.transparent; // No borders for neumorphism
const lTextPrimary = Color(0xFF2D3748);   // Dark gray (near-black) for readability
const lTextSecondary = Color(0xFF4A5568); // Medium-dark gray for secondary text

// ─── Shared constants ───────────────────────────────────────────────────
const kAccent1 = Color(0xFF6C63FF);
const kAccent2 = Color(0xFF48CAE4);
const kAccent3 = Color(0xFFFF6584);

// Backward-compatible aliases
const kBg1 = dBg1;
const kBg2 = dBg2;
const kGlass = dGlass;
const kGlassBorder = dGlassBorder;
const kTextPrimary = dTextPrimary;
const kTextSecondary = dTextSecondary;

// Helper — get dark/light colors based on brightness
extension ThemeColors on BuildContext {
  Color get bg1 => isDark ? dBg1 : lBgStart;
  Color get bg2 => isDark ? dBg2 : lBgEnd;
  Color get surface => isDark ? const Color(0x1AFFFFFF) : lSurface;
  Color get glass => isDark ? dGlass : lGlass;
  Color get glassBorder => isDark ? dGlassBorder : lGlassBorder;
  Color get textPrimary => isDark ? dTextPrimary : lTextPrimary;
  Color get textSecondary => isDark ? dTextSecondary : lTextSecondary;
  Color get accent1 => kAccent1;
  Color get accent2 => kAccent2;
  Color get accent3 => kAccent3;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [dBg1, dBg2, Color(0xFF1A0533)],
                  stops: [0.0, 0.5, 1.0],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lBgStart,
                    lBgBase,
                    lBgEnd,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
        ),
        child: ClipRect(
          child: Stack(
            children: [
              // Remove cloud texture and backdrop blur for clean neumorphic design in light mode
              if (isDark)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CloudTexturePainter(),
                  ),
                ),
              if (isDark)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: Colors.black.withValues(alpha: 0)),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// Cloud texture painter for light mode background
class _CloudTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Soft white cloud-like patches
    for (int i = 0; i < 8; i++) {
      final x = (i * 0.137 + 0.3) * size.width;
      final y = (i * 0.124 + 0.1) * size.height;
      final radius = size.width * (0.15 + i * 0.02);
      paint.color = Colors.white.withValues(alpha: 0.12 - i * 0.01);
      canvas.drawCircle(Offset(x % size.width, y % size.height), radius, paint);
    }
    
    // Subtle wispy clouds
    for (int i = 0; i < 5; i++) {
      final x = (i * 0.2 + 0.1) * size.width;
      final y = (i * 0.18 + 0.6) * size.height;
      paint.color = Colors.white.withValues(alpha: 0.06);
      canvas.drawOval(Rect.fromCenter(center: Offset(x % size.width, y % size.height), width: size.width * 0.4, height: size.height * 0.12), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Glass card with support for both frosted glass (dark mode) and neumorphism (light mode)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final double blurIntensity;
  final bool? flat; // Disable neumorphic shadows if needed

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
    this.onTap,
    this.blurIntensity = 8,
    this.flat = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? dGlass : lGlass);
    final borderColor = isDark ? dGlassBorder : lGlassBorder;

    Widget card;

    if (isDark) {
      // Dark mode: keep original frosted glass effect
      card = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: child,
          ),
        ),
      );
    } else {
      // Light mode: neumorphic design with soft shadows
      List<BoxShadow> neumorphicShadows = flat! ? [] : [
        // Darker blue shadow (bottom-right) - matches sky theme
        BoxShadow(
          color: const Color(0xFF90B8D8).withValues(alpha: 0.6),
          offset: const Offset(8, 8),
          blurRadius: 16,
          spreadRadius: -4,
        ),
        // Lighter sky blue highlight (top-left)
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.9),
          offset: const Offset(-8, -8),
          blurRadius: 16,
          spreadRadius: -4,
        ),
      ];

      card = Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: neumorphicShadows,
        ),
        child: child,
      );
    }

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF3182CE).withValues(alpha: 0.08),
          highlightColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF3182CE).withValues(alpha: 0.05),
          child: card,
        ),
      );
    }

    return card;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? dTextPrimary : lTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? dTextSecondary : lTextSecondary),
        prefixIcon: Icon(prefixIcon, color: isDark ? dTextSecondary : lTextSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? dGlass : lGlass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? dGlassBorder : lGlassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? dGlassBorder : lGlassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kAccent1, width: 1.5),
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
              ? [Colors.grey.shade400, Colors.grey.shade300]
              : colors,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: disabled ? [] : [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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

// ── AI Assistant Bubble ──────────────────────────────────────────────────
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
      duration: const Duration(milliseconds: 200),
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
      _messages.add({'role': 'ai', 'text': _getAutoReply(text)});
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
    if (q.contains('theme') || q.contains('dark') || q.contains('light') || q.contains('mode')) {
      return 'You can toggle between dark and light mode from the sidebar menu.';
    }
    if (q.contains('creator') || q.contains('who made') || q.contains('team') || q.contains('developer')) {
      return 'PhotoSync was built by:\n• Habibun-najal Kayting (Lead Developer)\n• Hareeja Montenegro (Sub-dev & QA)\n• Mohd Shaffiqh (Sub-dev & Documentation)';
    }
    return 'Hi! I can help you navigate PhotoSync. Ask me about students, subjects, scanning, grades, or emails.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatBg = isDark ? const Color(0xFF1A1A3E) : const Color(0xCCFFFFFF);
    final msgBg = isDark ? dGlass : lGlass;

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
              decoration: BoxDecoration(
                color: chatBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? dGlassBorder : lGlassBorder),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [kAccent1, kAccent2]),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('PhotoSync AI',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        GestureDetector(
                          onTap: _toggle,
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                              'Hi! Ask me anything about PhotoSync 👋',
                                style: TextStyle(
                                  color: isDark ? dTextSecondary : lTextSecondary,
                                  fontSize: 13,
                                ),
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
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  constraints: const BoxConstraints(maxWidth: 220),
                                  decoration: BoxDecoration(
                                    gradient: isUser
                                        ? const LinearGradient(colors: [kAccent1, kAccent2])
                                        : null,
                                    color: isUser ? null : msgBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isUser ? null : Border.all(color: isDark ? dGlassBorder : lGlassBorder),
                                  ),
                                  child: Text(msg['text']!,
                                      style: TextStyle(
                                        color: isUser ? Colors.white : (isDark ? dTextPrimary : lTextPrimary),
                                        fontSize: 12,
                                      )),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(
                              color: isDark ? dTextPrimary : lTextPrimary,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ask something...',
                              hintStyle: TextStyle(
                                color: isDark ? dTextSecondary : lTextSecondary,
                                fontSize: 12,
                              ),
                              filled: true,
                              fillColor: msgBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDark ? dGlassBorder : lGlassBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDark ? dGlassBorder : lGlassBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: kAccent1, width: 1.5),
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
                              gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                  color: kAccent1.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }
}

ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: kAccent1,
      secondary: kAccent2,
      surface: dBg1,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: dTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: dTextPrimary),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: dTextPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: dTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: dTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: dTextPrimary),
      bodyMedium: TextStyle(color: dTextSecondary),
      bodySmall: TextStyle(color: dTextSecondary),
    ),
  );
}

ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: kAccent1,
      secondary: kAccent2,
      surface: lBgStart,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: lTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: lTextPrimary),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: lTextPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: lTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: lTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: lTextPrimary),
      bodyMedium: TextStyle(color: lTextSecondary),
      bodySmall: TextStyle(color: lTextSecondary),
    ),
  );
}