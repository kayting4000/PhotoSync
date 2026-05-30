import 'dart:ui';
import 'package:flutter/material.dart';

// Neumorphic Light Mode Colors
const nBgBase = Color(0xFFF0F0F5);
const nTextPrimary = Color(0xFF2D2D3D);
const nTextSecondary = Color(0xFF6B6B7D);
const nTextTertiary = Color(0xFF9B9BAD);
const nSurface = Color(0xFFFAFAFC);
const nShadowDark = Color(0x1A000000);
const nShadowLight = Color(0x4DFFFFFF);
const nBorder = Color(0xFFE0E0E8);
const nAccent = Color(0xFF7C3AED);

// Neumorphic Glass Card for Light Mode
class NeumorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double elevation;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.onTap,
    this.elevation = 1.0,
  });

  @override
  State<NeumorphicCard> createState() => _NeumorphicCardState();
}

class _NeumorphicCardState extends State<NeumorphicCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _pressController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _pressController.reverse();
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final depth = _isPressed ? 0.5 : widget.elevation;
          return Container(
            padding: widget.padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: nSurface,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: nShadowDark,
                  blurRadius: 12 * depth,
                  offset: Offset(4 * depth, 4 * depth),
                ),
                BoxShadow(
                  color: nShadowLight,
                  blurRadius: 12 * depth,
                  offset: Offset(-4 * depth, -4 * depth),
                ),
              ],
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

// Neumorphic Button
class NeumorphicButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 54,
    this.borderRadius = 16,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final depth = _pressController.value;
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)],
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.3 * (1 - depth)),
                  blurRadius: 16 * (1 - depth),
                  offset: Offset(4 * (1 - depth), 4 * (1 - depth)),
                ),
                BoxShadow(
                  color: nShadowLight,
                  blurRadius: 12 * (1 - depth),
                  offset: Offset(-3 * (1 - depth), -3 * (1 - depth)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: Colors.white.withValues(alpha: 0.1),
                child: Center(child: widget.child),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Neumorphic Icon Button
class NeumorphicIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final Color? color;

  const NeumorphicIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 48,
    this.color,
  });

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _pressController.reverse(),
      onTapCancel: () => _pressController.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          final depth = _pressController.value;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: nSurface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: nShadowDark,
                  blurRadius: 10 * (1 - depth),
                  offset: Offset(3 * (1 - depth), 3 * (1 - depth)),
                ),
                BoxShadow(
                  color: nShadowLight,
                  blurRadius: 10 * (1 - depth),
                  offset: Offset(-3 * (1 - depth), -3 * (1 - depth)),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onPressed,
                customBorder: const CircleBorder(),
                splashColor: nAccent.withValues(alpha: 0.1),
                child: Icon(widget.icon, color: widget.color ?? nTextPrimary, size: widget.size * 0.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
