import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/portfolio_repository.dart';
import '../../../core/services/supabase_service.dart';

part 'portfolio_provider.g.dart';

@riverpod
PortfolioRepository portfolioRepository(PortfolioRepositoryRef ref) {
  return PortfolioRepository(SupabaseService.client);
}

@riverpod
Future<List<Map<String, dynamic>>> portfolioBlocks(PortfolioBlocksRef ref, String userId) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.fetchPortfolio(userId);
}

@riverpod
Future<List<Map<String, dynamic>>> publicPortfolio(PublicPortfolioRef ref, String slug) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.fetchPublicPortfolio(slug);
}

final userPortfoliosProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.fetchUserPortfolios(userId);
});
