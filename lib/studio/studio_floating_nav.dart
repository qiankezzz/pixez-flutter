import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'studio_theme.dart';

class StudioNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const StudioNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Floating frosted-glass pill bottom navigation bar.
/// Tip: Set `extendBody: true` on your parent Scaffold so the artwork masonry grid
/// flows cleanly behind the translucent pill bar.
class StudioFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<StudioNavItem> items;

  const StudioFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.studio;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset > 0 ? bottomInset + 6 : 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 62,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: s.glassBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: s.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (i) {
                final active = i == currentIndex;
                final item = items[i];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: active ? s.accentSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            active ? item.activeIcon : item.icon,
                            size: 21,
                            color: active ? s.accent : s.textMuted,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: active ? s.accent : s.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
