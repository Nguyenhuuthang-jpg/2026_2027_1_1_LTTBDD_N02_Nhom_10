import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/genre.dart';

/// Chip chọn thể loại (dùng ở Khám phá và Quản lý bài hát).
class GenreChip extends StatelessWidget {
  const GenreChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
        selectedColor: AppTheme.primaryGreen,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? AppTheme.darkBackground : null,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
}

/// Hàng chip thể loại cuộn ngang, có lựa chọn "Tất cả" (id = null).
class GenreChipBar extends StatelessWidget {
  const GenreChipBar({
    super.key,
    required this.genres,
    required this.selectedId,
    required this.allLabel,
    required this.onChanged,
  });

  final List<Genre> genres;
  final int? selectedId;
  final String allLabel;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          GenreChip(
            label: allLabel,
            selected: selectedId == null,
            onSelected: () => onChanged(null),
          ),
          for (final g in genres)
            GenreChip(
              label: g.name,
              selected: selectedId == g.id,
              onSelected: () => onChanged(g.id),
            ),
        ],
      ),
    );
  }
}
