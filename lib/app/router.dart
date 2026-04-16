import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeshot/features/auth/presentation/login_screen.dart';
import 'package:vibeshot/features/discover/presentation/discover_screen.dart';
import 'package:vibeshot/features/feed/presentation/feed_screen.dart';
import 'package:vibeshot/features/gallery/presentation/photo_detail_screen.dart';
import 'package:vibeshot/features/gallery/presentation/upload_screen.dart';
import 'package:vibeshot/features/portfolio/presentation/portfolio_screen.dart';
import 'package:vibeshot/features/portfolio/presentation/portfolio_editor_screen.dart';
import 'package:vibeshot/features/profile/presentation/profile_screen.dart';
import 'package:vibeshot/features/explore/presentation/explore_screen.dart';
import 'package:vibeshot/shared/widgets/main_scaffold.dart';

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    // ── Auth ────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ── Main Shell (with bottom nav) ─────────────────────────
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        // Module 4: Discover Feed (home)
        GoRoute(
          path: '/',
          name: 'discover',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DiscoverScreen(),
          ),
        ),

        // Module 2: Social Feed
        GoRoute(
          path: '/feed',
          name: 'feed',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FeedScreen(),
          ),
        ),

        // Explore / Search
        GoRoute(
          path: '/explore',
          name: 'explore',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExploreScreen(),
          ),
        ),

        // Module 3: Portfolio
        GoRoute(
          path: '/portfolio',
          name: 'portfolio',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PortfolioScreen(),
          ),
          routes: [
            GoRoute(
              path: 'edit/:projectId',
              name: 'portfolio-edit',
              builder: (context, state) => PortfolioEditorScreen(
                projectId: state.pathParameters['projectId']!,
              ),
            ),
          ],
        ),

        // User Profile
        GoRoute(
          path: '/u/:username',
          name: 'profile',
          builder: (context, state) => ProfileScreen(
            username: state.pathParameters['username']!,
          ),
        ),
      ],
    ),

    // ── Photo Detail (full screen, outside shell) ─────────────
    GoRoute(
      path: '/photo/:photoId',
      name: 'photo-detail',
      builder: (context, state) => PhotoDetailScreen(
        photoId: state.pathParameters['photoId']!,
      ),
    ),

    // ── Upload ────────────────────────────────────────────────
    GoRoute(
      path: '/upload',
      name: 'upload',
      builder: (context, state) => const UploadScreen(),
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF0E0E0E),
    body: Center(
      child: Text(
        'Page not found',
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
    ),
  ),
);
