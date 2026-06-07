# 🎨 PhotoSync UI Components - Quick Reference

## Version: 2024.12.19+1

---

## 🎯 Quick Start

### Import Theme
```dart
import 'package:photosync/theme/app_theme.dart';
```

---

## 📦 Components

### 1. GlassCard (Enhanced)
Smooth glass-morphism card with hover animations.

```dart
GlassCard(
  padding: EdgeInsets.all(20),
  borderRadius: 20,
  blurIntensity: 16,
  elevation: 1.0,
  onTap: () => print('Tapped!'),
  child: Column(
    children: [
      Text('Title', style: AppTypography.heading),
      SizedBox(height: 10),
      Text('Content', style: AppTypography.body),
    ],
  ),
)
```

**Features:**
- ✨ Hover scale animation (1.0 → 1.02)
- 🎯 Border glow on interaction
- 📊 Dual shadow system
- 🔄 Smooth 300ms transitions

**Parameters:**
- `child` - Widget to display
- `padding` - Inner padding (default: 22)
- `borderRadius` - Corner radius (default: 20)
- `color` - Glass background color
- `onTap` - Tap callback
- `blurIntensity` - Blur amount (default: 16)
- `elevation` - Shadow depth (default: 1.0)
- `gradientColors` - Custom gradient

---

### 2. GradientButton (Enhanced)
Premium gradient button with press animations.

```dart
GradientButton(
  onPressed: () => print('Pressed!'),
  colors: [Color(0xFF7C3AED), Color(0xFF9D4EDD)],
  height: 54,
  borderRadius: 18,
  child: Text(
    'Click Me',
    style: AppTypography.label.copyWith(
      color: Colors.white,
      fontSize: 16,
    ),
  ),
)
```

**Features:**
- 🎬 Press animation (scale 1.0 → 0.98)
- ✨ Enhanced glow on press
- 🌊 Ripple effect
- 📊 Dual shadow system
- ⚡ Better visual feedback

**Parameters:**
- `onPressed` - Tap callback (null = disabled)
- `child` - Button content
- `colors` - Gradient colors
- `height` - Button height (default: 54)
- `borderRadius` - Corner radius (default: 18)

---

### 3. DynamicAvatar (Enhanced)
Colorful avatar with dynamic colors based on text.

```dart
DynamicAvatar(
  text: 'John Doe',
  size: 48,
)
```

**Features:**
- 🎨 Dynamic color based on first letter
- 📐 Dual shadow system
- ✨ Smooth gradient
- 🔤 Better typography

**Parameters:**
- `text` - Text to display (uses first letter)
- `size` - Avatar size (default: 48)
- `colors` - Custom gradient colors

**Color Mapping:**
```
A-B → Purple (#9D4EDD)
C-D → Light Purple (#C77DFF)
E-F → Magenta (#E040FB)
G-H → Blue (#4A9EFF)
I-J → Dark Blue (#448AFF)
K-L → Green (#4ADE80)
M-N → Orange (#FF8A65)
O-P → Pink (#FF4081)
```

---

### 4. GlassTextField
Premium text field with focus glow.

```dart
GlassTextField(
  controller: emailController,
  label: 'Email',
  prefixIcon: Icons.email,
  keyboardType: TextInputType.emailAddress,
)
```

**Features:**
- 🎯 Focus glow effect
- 📝 Smooth transitions
- ✨ Icon color changes on focus
- 🔤 Better typography

**Parameters:**
- `controller` - TextEditingController
- `label` - Field label
- `prefixIcon` - Leading icon
- `obscureText` - Hide text (default: false)
- `suffixIcon` - Trailing widget
- `keyboardType` - Keyboard type

---

### 5. PremiumFAB
Floating action button with gradient and glow.

```dart
PremiumFAB(
  onPressed: () => print('FAB pressed!'),
  icon: Icons.add,
  size: 56,
)
```

**Features:**
- 🎨 Gradient background
- ✨ Dual shadow glow
- 📱 Perfect for mobile
- 🎯 Large touch target

**Parameters:**
- `onPressed` - Tap callback
- `icon` - Button icon
- `size` - Button size (default: 56)

---

### 6. BadgePill
Small badge/pill component.

```dart
BadgePill(
  label: 'New',
  color: kSuccess,
  fontSize: 11,
)
```

**Features:**
- 🎨 Colored background
- 📐 Rounded corners
- ✨ Subtle border
- 🔤 Custom font size

**Parameters:**
- `label` - Badge text
- `color` - Badge color (default: kAccentVivid)
- `fontSize` - Text size (default: 11)

---

### 7. PremiumDivider
Gradient divider line.

```dart
PremiumDivider(
  indent: 16,
  endIndent: 16,
)
```

**Features:**
- 🎨 Gradient effect
- 📐 Customizable margins
- ✨ Subtle styling
- 🔄 Smooth transitions

**Parameters:**
- `indent` - Left margin
- `endIndent` - Right margin

---

### 8. AIAssistantBubble
Interactive AI chat bubble.

```dart
Stack(
  children: [
    // Your content
    Positioned(
      bottom: 20,
      right: 20,
      child: AIAssistantBubble(),
    ),
  ],
)
```

**Features:**
- 💬 Chat interface
- 🎬 Smooth animations
- 📱 Mobile-friendly
- 🤖 Auto-reply system

---

### 9. AppBackground
Full-screen background with orbs and texture.

```dart
AppBackground(
  showOrbs: true,
  child: Scaffold(
    body: YourContent(),
  ),
)
```

**Features:**
- 🎨 Gradient background
- ✨ Animated orbs
- 📐 Cloud texture
- 🔄 Blur effect

**Parameters:**
- `child` - Content widget
- `showOrbs` - Show animated orbs (default: false)

---

### 10. FrostedAppBar
Premium app bar with glass effect.

```dart
Scaffold(
  appBar: FrostedAppBar(
    title: Text('Title'),
    actions: [
      IconButton(icon: Icon(Icons.search), onPressed: () {}),
    ],
  ),
  body: YourContent(),
)
```

**Features:**
- 🎨 Glass effect
- ✨ Blur background
- 📐 Smooth transitions
- 🔤 Premium typography

---

## 🎨 Colors

### Accent Colors
```dart
kAccentVivid      // #9D4EDD - Primary purple
kAccentAmethyst   // #C77DFF - Light purple
kAccentMagenta    // #E040FB - Bright magenta
kAccentIndigo     // #7C3AED - Deep purple
kAccentViolet     // #A855F7 - Vibrant purple
```

### Text Colors
```dart
kTextPrimary      // #F5F5F7 - Bright off-white
kTextSecondary    // #B0A8C0 - Muted lavender
kTextTertiary     // #7A7288 - Dimmed
kTextWhite        // #FFFFFF - Pure white
```

### Status Colors
```dart
kSuccess          // #4ADE80 - Green
kWarning          // #FFC107 - Yellow
kError            // #FF4081 - Pink
kInfo             // #4A9EFF - Blue
```

### Icon Colors
```dart
kIconPurple       // #9D4EDD
kIconBlue         // #4A9EFF
kIconGreen        // #4ADE80
kIconOrange       // #FF8A65
kIconPink         // #FF4081
kIconTeal         // #26C6DA
kIconRed          // #FF6B6B
kIconYellow       // #FFD93D
```

---

## 🔤 Typography

### Heading
```dart
AppTypography.heading
// Poppins, Bold, -0.5 letter spacing
```

### Subheading
```dart
AppTypography.subheading
// Poppins, W600, 0 letter spacing
```

### Body
```dart
AppTypography.body
// Inter, Normal, 0 letter spacing
```

### Body Bold
```dart
AppTypography.bodyBold
// Inter, W600, 0 letter spacing
```

### Caption
```dart
AppTypography.caption
// Inter, Normal, 0.2 letter spacing
```

### Label
```dart
AppTypography.label
// Poppins, W600, 0.5 letter spacing
```

---

## 🎬 Animations

### Hover Animation
```dart
// GlassCard automatically animates on hover
// Scale: 1.0 → 1.02
// Duration: 300ms
// Curve: easeOutCubic
```

### Press Animation
```dart
// GradientButton automatically animates on press
// Scale: 1.0 → 0.98
// Duration: Instant
```

### Pulse Animation
```dart
// GradientButton has continuous pulse
// Duration: 1500ms
// Curve: easeInOut
```

---

## 📱 Responsive Design

### Mobile-First Approach
```dart
// All components are optimized for mobile
// Larger touch targets (min 48x48)
// Better spacing on small screens
// Optimized animations for mobile
```

### Breakpoints
```dart
// Small: < 600px
// Medium: 600-900px
// Large: > 900px
```

---

## 🚀 Performance Tips

1. **Use AnimatedBuilder** for complex animations
2. **Dispose controllers** in State.dispose()
3. **Avoid rebuilding** entire widgets
4. **Use const** constructors when possible
5. **Profile** with DevTools

---

## 🐛 Troubleshooting

### Animation Jank
- Check if AnimationController is disposed
- Verify curve is appropriate
- Profile with DevTools

### Colors Look Wrong
- Check theme mode (dark/light)
- Verify color constants are imported
- Check opacity values

### Touch Not Responsive
- Ensure GestureDetector is wrapping widget
- Check if onTap callback is set
- Verify Material widget is present

---

## 📚 Examples

### Complete Screen
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      showOrbs: true,
      child: Scaffold(
        appBar: FrostedAppBar(
          title: Text('My Screen'),
        ),
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            GlassCard(
              child: Text('Card 1'),
            ),
            SizedBox(height: 16),
            GlassCard(
              child: Text('Card 2'),
            ),
          ],
        ),
        floatingActionButton: PremiumFAB(
          onPressed: () {},
          icon: Icons.add,
        ),
      ),
    );
  }
}
```

---

## 📞 Support

For issues or questions:
1. Check this guide
2. Review `lib/theme/app_theme.dart`
3. Check Flutter documentation
4. Ask in team chat

---

**Last Updated:** December 19, 2024
**Version:** 2024.12.19+1

