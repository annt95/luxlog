import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late PortfolioRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    repository = PortfolioRepository(mockSupabaseClient);
  });

  test('fetchPortfolio returns empty list on not found code', () async {
    when(() => mockSupabaseClient.from('portfolios')).thenThrow(
      const PostgrestException(
        message: 'No rows found',
        code: 'PGRST116',
      ),
    );

    final result = await repository.fetchPortfolio('user-1');

    expect(result, isEmpty);
  });
}
