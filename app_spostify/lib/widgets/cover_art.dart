import 'package:flutter/material.dart';

/// Ảnh bìa bài hát / playlist. Nếu không có URL thì vẽ nền gradient
/// (màu cố định theo [seed] để mỗi bài luôn có cùng một màu).
class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    this.url,
    required this.seed,
    this.size = 48,
    this.radius = 10,
    this.icon = Icons.music_note_rounded,
  });

  final String? url;
  final String seed;
  final double size;
  final double radius;
  final IconData icon;

  static const List<List<Color>> _palettes = [
    [Color(0xFF1ED760), Color(0xFF0B6E4F)],
    [Color(0xFF6A5AE0), Color(0xFF2E2A6B)],
    [Color(0xFFFF7A59), Color(0xFF8C2F39)],
    [Color(0xFF2BB5FF), Color(0xFF1B4F8C)],
    [Color(0xFFF7C948), Color(0xFFB4690E)],
    [Color(0xFFE85D9A), Color(0xFF6B1F4B)],
  ];

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[seed.hashCode.abs() % _palettes.length];
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: size * 0.45),
      ),
    );

    final hasUrl = url != null && url!.trim().isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: hasUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : placeholder,
              )
            : placeholder,
      ),
    );
  }
}
