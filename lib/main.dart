import 'package:flutter/material.dart';
import 'note_screen.dart';

void main() {
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  // Tạo ValueNotifier để theo dõi trạng thái Dark Mode
  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Note App',
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: NoteScreen(),
        );
      },
    );
  }
}
