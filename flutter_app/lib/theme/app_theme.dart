import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Premium Typography Configuration ─────────────────────────────────
class AppTypography {
  static final heading = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  static final subheading = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static final body = GoogleFonts.inter(
    fontWeight: FontWeight.normal,
    letterSpacing: 0,
  );
  static final bodyBold = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static final caption = GoogleFonts.inter(
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );
  static final label = GoogleFonts.poppins(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  static final decorative = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );
}

// ═══════════════════════════════════════════════════════════════════════
// PREMIUM DARK MODE COLOR PALETTE
// ═══════════════════════════════════════════════════════════════════════

// Deep dark gradient backgrounds
const kBgDeep1 = Color(0xFF0B0813);
const kBgDeep2 = Color(0xFF1A0B2E);
const kBgDeep3 = Color(0xFF11081E);

// Purple accents - Enhanced vibrant palette
const kAccentVivid = Color(0xFF9D4EDD);
const kAccentAmethyst = Color(0xFFC77DFF);
const kAccentMagenta = Color(0xFFE040FB);
const kAccentIndigo = Color(0xFF7C3AED);
const kAccentViolet = Color(0xFFA855F7);

// Glass layer colors - Enhanced transparency
const kGlassBg = Color(0x1AFFFFFF);     // 10% white for deep glass
const kGlassBgLighter = Color(0x29FFFFFF); // 16% white for lighter glass
const kGlassBorder = Color(0x14FFFFFF);   // 8% white border
const kGlassBorderFocused = Color(0x3DFFFFFF); // 24% white for focused

// Text colors - high contrast
const kTextPrimary = Color(0xFFF5F5F7);  // Bright off-white for titles
const kTextSecondary = Color(0xFFB0A8C0); // Muted silver/lavender
const kTextTertiary = Color(0xFF7A7288);  // Dimmed for placeholders
const kTextWhite = Colors.white;

// Icon container colors (vibrant category colors)
const kIconPurple = Color(0xFF9D4EDD);
const kIconBlue = Color(0xFF4A9EFF);
const kIconGreen = Color(0xFF4ADE80);
const kIconOrange = Color(0xFFFF8A65);
const kIconPink = Color(0xFFFF4081);
const kIconTeal = Color(0xFF26C6DA);
const kIconRed = Color(0xFFFF6B6B);
const kIconYellow = Color(0xFFFFD93D);

// Dynamic avatar colors
const List<Color> avatarColors = [
  Color(0xFF9D4EDD),
  Color(0xFFC77DFF),
  Color(0xFFE040FB),
  Color(0xFF4A9EFF),
  Color(0xFF448AFF),
  Color(0xFF4ADE80),
  Color(0xFFFF8A65),
  Color(0xFFFF4081),
];

// ─── Light mode - Pure Neumorphism ──────────────────────────────────
const lBgBase = Color(0xFFF0F0F5);
const lTextPrimary = Color(0xFF2D2D3D);
const lTextSecondary = Color(0xFF6B6B7D);
const lTextTertiary = Color(0xFF9B9BAD);
const lSurface = Color(0xFFF0F0F5);
const lGlass = Color(0xFFFAFAFC);
const lGlassBorder = Color(0xFFE0E0E8);
const lShadowDark = Color(0x1A000000);
const lShadowLight = Color(0x4DFFFFFF);

// ─── Backward-compatible aliases for existing screens ───────────────
const kAccent1 = kAccentVivid;
const kAccent2 = kAccentAmethyst;
const kAccent3 = kAccentMagenta;
const kSuccess = Color(0xFF4ADE80);
const kWarning = Color(0xFFFFC107);
const kError = Color(0xFFFF4081);
const kInfo = Color(0xFF4A9EFF);
const kGlass = kGlassBg;

// Old color names (for screens that reference them directly)
const dBg1 = kBgDeep1;
const dBg2 = kBgDeep2;
const dGlass = kGlassBg;
const dGlassBorder = kGlassBorder;
const dTextPrimary = kTextWhite;
const dTextSecondary = kTextSecondary;
const dTextTertiary = kTextTertiary;
const dSurfaceElevated = kGlassBg;
const lBgStart = lSurface;
const lBgEnd = lSurface;
const lSurfaceElevated = Color(0xFFFFFFFF);

// Helper extension
extension ThemeColors on BuildContext {
  Color get textPrimary => kTextPrimary;
  Color get textSecondary => kTextSecondary;
  Color get textTertiary => kTextTertiary;
  Color get accent1 => kAccentVivid;
  Color get accent2 => kAccentAmethyst;
  Color get accent3 => kAccentMagenta;
  Color get glass => kGlassBg;
  Color get glassBorder => kGlassBorder;
  Color get surface => kGlassBgLighter;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// ═══════════════════════════════════════════════════════════════════════
// DECORATIVE BACKGROUND with ANIMATED ORBS
// ═══════════════════════════════════════════════════════════════════════
class _OrbPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft, low-opacity background orbs that don't fight with text
    final paint1 = Paint()..shader = RadialGradient(
      colors: [kAccentVivid.withValues(alpha: 0.08), kAccentVivid.withValues(alpha: 0)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.85, size.height * 0.15), radius: size.width * 0.35));
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), size.width * 0.35, paint1);

    final paint2 = Paint()..shader = RadialGradient(
      colors: [kAccentMagenta.withValues(alpha: 0.05), kAccentMagenta.withValues(alpha: 0)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.2, size.height * 0.8), radius: size.width * 0.28));
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), size.width * 0.28, paint2);

    final paint3 = Paint()..shader = RadialGradient(
      colors: [kAccentAmethyst.withValues(alpha: 0.06), kAccentAmethyst.withValues(alpha: 0)],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(size.width * 0.6, size.height * 0.5), radius: size.width * 0.15));
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.5), size.width * 0.15, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CloudTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final x = (i * 0.15 + 0.3) * size.width;
      final y = (i * 0.13 + 0.1) * size.height;
      final radius = size.width * (0.12 + i * 0.02);
      paint.color = Colors.white.withValues(alpha: 0.04 - i * 0.005);
      canvas.drawCircle(Offset(x % size.width, y % size.height), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════
// APP BACKGROUND
// ═══════════════════════════════════════════════════════════════════════
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showOrbs;
  const AppBackground({super.key, required this.child, this.showOrbs = false});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kBgDeep1, kBgDeep2, kBgDeep3],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: ClipRect(
          child: Stack(
            children: [
              if (showOrbs)
                Positioned.fill(child: CustomPaint(painter: _OrbPainter())),
              Positioned.fill(child: CustomPaint(painter: _CloudTexturePainter())),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(color: Colors.white.withValues(alpha: 0.02)),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PREMIUM GLASS CONTAINER with ENHANCED ANIMATIONS
// ═══════════════════════════════════════════════════════════════════════
class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final double blurIntensity;
  final bool? flat;
  final List<Color>? gradientColors;
  final double elevation;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
    this.onTap,
    this.blurIntensity = 16,
    this.flat = false,
    this.gradientColors,
    this.elevation = 1.0,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _hoverAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.color ?? kGlassBg;
    final borderColor = kGlassBorder;

    Widget card = AnimatedBuilder(
      animation: _hoverAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_hoverAnim.value * 0.02),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: widget.blurIntensity, sigmaY: widget.blurIntensity),
              child: Container(
                padding: widget.padding ?? const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: widget.gradientColors != null
                      ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.gradientColors!)
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [bgColor, bgColor.withValues(alpha: 0.3)],
                        ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(color: borderColor.withValues(alpha: 0.5 + _hoverAnim.value * 0.5), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2 * widget.elevation),
                      blurRadius: 20 * widget.elevation,
                      offset: Offset(0, 5 * widget.elevation),
                    ),
                    BoxShadow(
                      color: kAccentVivid.withValues(alpha: 0.1 * _hoverAnim.value),
                      blurRadius: 30 * _hoverAnim.value,
                      offset: Offset(0, 10 * _hoverAnim.value),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      card = MouseRegion(
        onEnter: (_) {
          _hoverController.forward();
        },
        onExit: (_) {
          _hoverController.reverse();
        },
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: Colors.white.withValues(alpha: 0.08),
            highlightColor: Colors.white.withValues(alpha: 0.04),
            child: card,
          ),
        ),
      );
    }

    return card;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// GLASS TEXT FIELD with FOCUS GLOW
// ═══════════════════════════════════════════════════════════════════════
class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final bool autofocus;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.autofocus = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [BoxShadow(color: kAccentVivid.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 0))]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        autofocus: widget.autofocus,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        style: AppTypography.body.copyWith(color: kTextWhite, fontSize: 15),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: AppTypography.caption.copyWith(color: kTextTertiary, fontSize: 13),
          floatingLabelStyle: AppTypography.caption.copyWith(color: kAccentAmethyst, fontSize: 13),
          prefixIcon: Icon(widget.prefixIcon, color: _isFocused ? kAccentAmethyst : kTextTertiary, size: 20),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: kGlassBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kGlassBorder, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kGlassBorder, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kAccentVivid, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PREMIUM GRADIENT BUTTON with ENHANCED GLOW & RIPPLE
// ═══════════════════════════════════════════════════════════════════════
class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final List<Color> colors;
  final double height;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.colors = const [Color(0xFF7C3AED), Color(0xFF9D4EDD)],
    this.height = 54,
    this.borderRadius = 18,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final activeColors = disabled ? [Colors.grey.shade600, Colors.grey.shade500] : widget.colors;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: activeColors),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: disabled ? [] : [
            BoxShadow(color: activeColors.first.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: disabled ? [] : [
                  BoxShadow(
                    color: activeColors.first.withValues(alpha: 0.25 * _pulseAnim.value),
                    blurRadius: 35,
                    offset: const Offset(0, 15),
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: activeColors.first.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Transform.scale(
                    scale: _isPressed ? 0.98 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PREMIUM FAB
// ═══════════════════════════════════════════════════════════════════════
class PremiumFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;

  const PremiumFAB({super.key, required this.onPressed, required this.icon, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: kAccentVivid.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: kAccentVivid.withValues(alpha: 0.25), blurRadius: 35, offset: const Offset(0, 15)),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0, hoverElevation: 0, focusElevation: 0, highlightElevation: 0,
        child: Icon(icon, color: Colors.white, size: size * 0.46),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DYNAMIC AVATAR with ENHANCED STYLING
// ═══════════════════════════════════════════════════════════════════════
class DynamicAvatar extends StatelessWidget {
  final String text;
  final double size;
  final List<Color>? colors;

  DynamicAvatar({super.key, required this.text, this.size = 48, this.colors});

  Color _getColor(String text) {
    final index = text.codeUnitAt(0) % avatarColors.length;
    return avatarColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final colors = this.colors;
    final avatarColor = _getColor(text);
    final gradientColors = colors ?? [avatarColor, avatarColor.withValues(alpha: 0.6)];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.42,
            fontFamily: 'Poppins',
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PREMIUM SNACKBAR (glass-styled)
// ═══════════════════════════════════════════════════════════════════════
void showPremiumSnackBar(BuildContext context, String message, {Color? color}) {
  final overlay = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 20, left: 20, right: 20,
      child: Material(
        color: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          borderRadius: 16, blurIntensity: 20,
          color: color ?? const Color(0xAAF5F5F7),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: kSuccess, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: AppTypography.body.copyWith(color: kTextWhite, fontSize: 13))),
          ]),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlay);
  Future.delayed(const Duration(seconds: 2), () => overlay.remove());
}

// ═══════════════════════════════════════════════════════════════════════
// BADGE PILL
// ═══════════════════════════════════════════════════════════════════════
class BadgePill extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const BadgePill({super.key, required this.label, this.color = kAccentVivid, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(label, style: AppTypography.label.copyWith(color: color, fontSize: fontSize, letterSpacing: 0.3)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PREMIUM DIVIDER
// ═══════════════════════════════════════════════════════════════════════
class PremiumDivider extends StatelessWidget {
  final double indent;
  final double endIndent;
  const PremiumDivider({super.key, this.indent = 0, this.endIndent = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent, right: endIndent),
      height: 0.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.transparent,
          kGlassBorder,
          kAccentVivid.withValues(alpha: 0.3),
          kGlassBorder,
          Colors.transparent,
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// AI ASSISTANT BUBBLE
// ═══════════════════════════════════════════════════════════════════════
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
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) _animController.forward(); else _animController.reverse();
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
      return 'PhotoSync was built by:\n\u2022 Habibun-najal Kayting (Lead Developer)\n\u2022 Hareeja Montenegro (Sub-dev & QA)\n\u2022 Mohd Shaffiqh (Sub-dev & Documentation)';
    }
    return 'Hi! I can help you navigate PhotoSync. Ask me about students, subjects, scanning, grades, or emails.';
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
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 20,
              blurIntensity: 20,
              color: const Color(0xFF1A1035),
              child: SizedBox(
                width: 300, height: 380,
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text('PhotoSync AI', style: AppTypography.subheading.copyWith(color: Colors.white, fontSize: 14))),
                      GestureDetector(onTap: _toggle, child: const Icon(Icons.close_rounded, color: Colors.white, size: 18)),
                    ]),
                  ),
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text('Hi! Ask me anything about PhotoSync \u{1F44B}',
                            style: AppTypography.body.copyWith(color: kTextSecondary, fontSize: 13), textAlign: TextAlign.center)))
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
                                    gradient: isUser ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]) : null,
                                    color: isUser ? null : kGlassBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isUser ? null : Border.all(color: kGlassBorder),
                                  ),
                                  child: Text(msg['text']!,
                                    style: AppTypography.body.copyWith(color: isUser ? Colors.white : kTextWhite, fontSize: 12)),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: AppTypography.body.copyWith(color: kTextWhite, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Ask something...',
                            hintStyle: AppTypography.caption.copyWith(color: kTextTertiary, fontSize: 12),
                            filled: true, fillColor: kGlassBg,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kGlassBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kGlassBorder)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kAccentVivid, width: 1.5)),
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
                            gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: kAccentVivid.withValues(alpha: 0.45), blurRadius: 12, offset: const Offset(0, 4)),
                BoxShadow(color: kAccentVivid.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// FROSTED APP BAR
// ═══════════════════════════════════════════════════════════════════════
class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;

  const FrostedAppBar({super.key, this.title, this.actions, this.leading});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: kBgDeep1.withValues(alpha: 0.6),
            border: Border(bottom: BorderSide(color: kGlassBorder, width: 0.5)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: title,
            actions: actions,
            leading: leading,
            iconTheme: const IconThemeData(color: kTextWhite),
            titleTextStyle: AppTypography.subheading.copyWith(color: kTextWhite, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// THEME BUILDER
// ═══════════════════════════════════════════════════════════════════════
ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(primary: kAccentVivid, secondary: kAccentAmethyst, surface: kBgDeep2),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: kTextWhite),
    ),
    textTheme: TextTheme(
      headlineLarge: AppTypography.heading.copyWith(color: kTextWhite, fontSize: 32),
      headlineMedium: AppTypography.heading.copyWith(color: kTextWhite, fontSize: 26),
      headlineSmall: AppTypography.subheading.copyWith(color: kTextWhite, fontSize: 20),
      titleLarge: AppTypography.subheading.copyWith(color: kTextWhite, fontSize: 18),
      titleMedium: AppTypography.bodyBold.copyWith(color: kTextWhite, fontSize: 16),
      titleSmall: AppTypography.bodyBold.copyWith(color: kTextWhite, fontSize: 14),
      bodyLarge: AppTypography.body.copyWith(color: kTextWhite, fontSize: 16),
      bodyMedium: AppTypography.body.copyWith(color: kTextSecondary, fontSize: 14),
      bodySmall: AppTypography.body.copyWith(color: kTextSecondary, fontSize: 12),
      labelLarge: AppTypography.label.copyWith(color: kTextWhite, fontSize: 14),
      labelMedium: AppTypography.label.copyWith(color: kTextSecondary, fontSize: 12),
      labelSmall: AppTypography.caption.copyWith(color: kTextTertiary, fontSize: 10),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    dialogBackgroundColor: Colors.transparent,
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF1E1233),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: kGlassBorder, thickness: 0.5, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: kGlassBg,
      labelStyle: AppTypography.caption.copyWith(color: kTextWhite, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: kGlassBorder),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: AppTypography.label.copyWith(color: kTextWhite, fontSize: 12),
      unselectedLabelStyle: AppTypography.caption.copyWith(color: kTextSecondary, fontSize: 12),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
  );
}

// Keep light theme for backward compatibility
ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(primary: kAccentVivid, secondary: kAccentAmethyst, surface: lSurface),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: lTextPrimary),
    ),
    textTheme: TextTheme(
      headlineLarge: AppTypography.heading.copyWith(color: lTextPrimary, fontSize: 32),
      headlineMedium: AppTypography.heading.copyWith(color: lTextPrimary, fontSize: 26),
      headlineSmall: AppTypography.subheading.copyWith(color: lTextPrimary, fontSize: 20),
      titleLarge: AppTypography.subheading.copyWith(color: lTextPrimary, fontSize: 18),
      titleMedium: AppTypography.bodyBold.copyWith(color: lTextPrimary, fontSize: 16),
      titleSmall: AppTypography.bodyBold.copyWith(color: lTextPrimary, fontSize: 14),
      bodyLarge: AppTypography.body.copyWith(color: lTextPrimary, fontSize: 16),
      bodyMedium: AppTypography.body.copyWith(color: lTextSecondary, fontSize: 14),
      bodySmall: AppTypography.body.copyWith(color: lTextSecondary, fontSize: 12),
      labelLarge: AppTypography.label.copyWith(color: lTextPrimary, fontSize: 14),
      labelMedium: AppTypography.label.copyWith(color: lTextSecondary, fontSize: 12),
      labelSmall: AppTypography.caption.copyWith(color: lTextTertiary, fontSize: 10),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
    ),
    dialogBackgroundColor: Colors.transparent,
    popupMenuTheme: PopupMenuThemeData(
      color: lSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(color: lGlassBorder, thickness: 0.5, space: 1),
    chipTheme: ChipThemeData(
      backgroundColor: lGlass,
      labelStyle: AppTypography.caption.copyWith(color: lTextPrimary, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: lGlassBorder),
    ),
    tabBarTheme: TabBarThemeData(
      labelStyle: AppTypography.label.copyWith(color: lTextPrimary, fontSize: 12),
      unselectedLabelStyle: AppTypography.caption.copyWith(color: lTextSecondary, fontSize: 12),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)]),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
  );
}