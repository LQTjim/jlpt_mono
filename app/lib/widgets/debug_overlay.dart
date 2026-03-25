import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 可拖移的懸浮 debug 按鈕，只在 debug mode 顯示。
/// 展開後提供各種開發測試工具。
class DebugOverlay extends StatefulWidget {
  final Widget child;

  const DebugOverlay({super.key, required this.child});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  Offset _position = const Offset(16, 100);
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: _expanded ? _buildMenu() : _buildFab(),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
        });
      },
      onTap: () => setState(() => _expanded = true),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.terracottaDark.withValues(alpha: 0.85),
          borderRadius: AppSpacing.radiusFull,
          boxShadow: AppSpacing.elevatedShadow,
        ),
        child: const Icon(Icons.bug_report, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildMenu() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _position += details.delta;
        });
      },
      child: Material(
        elevation: 8,
        borderRadius: AppSpacing.radiusMd,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: AppSpacing.radiusMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Debug Menu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _expanded = false),
                    child: const Icon(Icons.close, size: 20, color: AppColors.textHint),
                  ),
                ],
              ),
              const Divider(),
              _menuItem(
                icon: Icons.language,
                label: '重設語言選擇',
                onTap: () {
                  context.read<LocaleProvider>().clearLocale();
                  setState(() => _expanded = false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.radiusSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
