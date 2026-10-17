import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakina_mobile/core/storage/key_value_store.dart';

/// Whether the user finished onboarding on this device (ONB-2 AC6).
class OnboardingStatus extends Notifier<bool> {
  static const String storageKey = 'onboarding.complete';

  @override
  bool build() =>
      ref.watch(keyValueStoreProvider).getBool(storageKey) ?? false;

  Future<void> markComplete() async {
    state = true;
    await ref.read(keyValueStoreProvider).setBool(storageKey, value: true);
  }
}

final NotifierProvider<OnboardingStatus, bool> onboardingStatusProvider =
    NotifierProvider<OnboardingStatus, bool>(OnboardingStatus.new);
