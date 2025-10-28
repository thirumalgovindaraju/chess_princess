import 'package:flutter/material.dart';
import '../models/board_theme.dart';
import '../services/theme_service.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Board Theme'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: BoardTheme.allThemes.length,
          itemBuilder: (context, index) {
            final theme = BoardTheme.allThemes[index];
            return _ThemeOption(theme: theme);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final BoardTheme theme;

  const _ThemeOption({required this.theme});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final isSelected = themeService.currentTheme.name == theme.name;

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(color: theme.lightSquare),
            ),
            Expanded(
              child: Container(color: theme.darkSquare),
            ),
          ],
        ),
      ),
      title: Text(
        theme.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.deepPurple)
          : null,
      onTap: () {
        themeService.setTheme(theme);
        Navigator.pop(context);
      },
    );
  }
}