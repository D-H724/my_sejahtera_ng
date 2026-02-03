import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sejahtera_ng/features/gamification/providers/user_progress_provider.dart';

class ThemeNotifier extends Notifier<String> {
  @override
  String build() {
    return 'default';
  }

  void setTheme(String themeId, UserProgress progress) {
    if (progress.unlockedThemes.contains(themeId)) {
      state = themeId;
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, String>(ThemeNotifier.new);
