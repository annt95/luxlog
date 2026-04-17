import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/features/profile/providers/follow_state_provider.dart';

void main() {
  group('FollowStateProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state contains mock data', () {
      final state = container.read(followStateProvider);
      expect(state.contains('sarahkwon'), isTrue);
      expect(state.contains('alexm'), isTrue);
      expect(state.length, 2);
    });

    test('toggleFollow adds user if not following', () {
      final notifier = container.read(followStateProvider.notifier);
      
      // Toggle a new user
      notifier.toggleFollow('newuser');
      
      final state = container.read(followStateProvider);
      expect(state.contains('newuser'), isTrue);
      expect(state.length, 3);
    });

    test('toggleFollow removes user if already following', () {
      final notifier = container.read(followStateProvider.notifier);
      
      // Ensure 'sarahkwon' is in state currently
      expect(container.read(followStateProvider).contains('sarahkwon'), isTrue);

      // Toggle existing user
      notifier.toggleFollow('sarahkwon');
      
      final state = container.read(followStateProvider);
      expect(state.contains('sarahkwon'), isFalse);
      expect(state.length, 1);
    });

    test('contains returns correct boolean', () {
      final state = container.read(followStateProvider);

      expect(state.contains('sarahkwon'), isTrue);
      expect(state.contains('unknown_user'), isFalse);
    });
  });
}
