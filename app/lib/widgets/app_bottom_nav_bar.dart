import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppNavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppNavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final List<AppNavItemData> items;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.inkDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: -15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 4,
            child: CustomPaint(painter: _WavyTopLinePainter(color: borderColor)),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (int i = 0; i < items.length; i++)
                    _AppNavItem(
                      data: items[i],
                      isSelected: selectedIndex == i,
                      onTap: () => onItemTap(i),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WavyTopLinePainter extends CustomPainter {
  final Color color;

  _WavyTopLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    
    // Draw a bumpy/sketchy straight horizontal line
    const int segments = 16;
    final double step = size.width / segments;
    for (int i = 1; i <= segments; i++) {
       // deterministic wobble pattern for sketch feel
       double waveOffset = (i % 2 != 0) ? -1.0 : 1.0;
       if (i % 3 == 0) waveOffset = 0.0;
       path.lineTo(i * step, size.height / 2 + waveOffset);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyTopLinePainter old) => old.color != color;
}

class _AppNavItem extends StatelessWidget {
  final AppNavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  static final Matrix4 _scaleUp = Matrix4.diagonal3Values(1.1, 1.1, 1.0);
  static final Matrix4 _scaleNormal = Matrix4.identity();

  const _AppNavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const selectedColor = AppColors.terracottaMuted;
    final unselectedColor =
        isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final color = isSelected ? selectedColor : unselectedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8.0),
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: selectedColor, width: 2.0),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.elliptical(11, 46),
                  topRight: Radius.elliptical(49, 14),
                  bottomRight: Radius.elliptical(12, 46),
                  bottomLeft: Radius.elliptical(48, 14),
                ),
              )
            : const BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.transparent, width: 2.0),
                ),
              ),
        transform: isSelected ? _scaleUp : _scaleNormal,
        transformAlignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? data.activeIcon : data.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              data.label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
