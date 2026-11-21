import 'dart:ui';
import 'package:material_ui/material_ui.dart';
import 'studio_theme.dart';

/// Gallery-first minimalist artwork card for PixEz masonry feeds.
/// Removes noisy bottom text bars by default while keeping 1-tap bookmarking & page count badge.
class StudioArtworkCard extends StatelessWidget {
  final Widget image;
  final String title;
  final String artistName;
  final int pageCount;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback? onLongPress;

  const StudioArtworkCard({
    super.key,
    required this.image,
    required this.title,
    required this.artistName,
    required this.pageCount,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.studio;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: s.surface,
          borderRadius: BorderRadius.circular(s.cardRadius),
          border: Border.all(color: s.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                image,
                if (pageCount > 1)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: Colors.black.withOpacity(0.58),
                          child: Text(
                            '${pageCount}P',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: onBookmarkTap,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isBookmarked
                                ? const Color(0xFFF43F5E)
                                : Colors.black.withOpacity(0.52),
                            border: Border.all(
                              color: isBookmarked
                                  ? const Color(0xFFF43F5E)
                                  : Colors.white.withOpacity(0.24),
                            ),
                          ),
                          child: Icon(
                            isBookmarked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!s.pureImageCard)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: s.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: s.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
