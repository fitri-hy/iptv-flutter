import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_manager.dart';
import '../themes/theme_colors.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.themeMode == ThemeMode.dark;

    return IconButton(
      icon: const Icon(Icons.color_lens),
      tooltip: "Theme & Color",
      onPressed: () async {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx,
            position.dy + button.size.height + 5,
            position.dx + button.size.width,
            0,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Theme.of(context).cardColor,
          items: [
            PopupMenuItem<String>(
              value: 'toggleDark',
              child: Row(
                children: [
                  Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(isDark ? "Light Mode" : "Dark Mode"),
                ],
              ),
            ),
            const PopupMenuDivider(),
            ...ThemeColors.colorMap.entries.map(
                  (entry) => PopupMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: entry.value.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      entry.key[0].toUpperCase() + entry.key.substring(1),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        if (selected == null) return;

        if (selected == 'toggleDark') {
          themeManager.updateTheme(!isDark, _colorName(themeManager.accentColor));
        } else {
          themeManager.updateTheme(isDark, selected);
        }
      },
    );
  }

  String _colorName(Color color) {
    return ThemeColors.colorMap.entries
        .firstWhere(
          (entry) => entry.value == color,
      orElse: () => const MapEntry('blue', Colors.blue),
    )
        .key;
  }
}
