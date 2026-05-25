import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hiddenActionsProvider = AsyncNotifierProvider<HiddenActionsNotifier, List<String>>(HiddenActionsNotifier.new);

class HiddenActionsNotifier extends AsyncNotifier<List<String>> {
  static const _key = 'dashboard_hidden_actions';

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> toggle(String label) async {
    final current = state.value ?? [];
    List<String> next;
    if (current.contains(label)) {
      next = current.where((l) => l != label).toList();
    } else {
      next = [...current, label];
    }
    state = AsyncData(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, next);
  }
}
