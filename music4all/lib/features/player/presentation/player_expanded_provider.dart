import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerExpandedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setExpanded(bool value) {
    state = value;
  }

  void toggle() {
    state = !state;
  }
}

final playerExpandedProvider = NotifierProvider<PlayerExpandedNotifier, bool>(
  () {
    return PlayerExpandedNotifier();
  },
);
