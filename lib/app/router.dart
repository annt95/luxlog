import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/features/auth/presentation/login_screen.dart';
import 'package:luxlog/features/auth/presentation/signup_screen.dart';
import 'package:luxlog/features/discover/presentation/discover_screen.dart';
import 'package:luxlog/features/feed/presentation/feed_screen.dart';
import 'package:luxlog/features/gallery/presentation/photo_detail_screen.dart';
import 'package:luxlog/features/gallery/presentation/upload_screen.dart';
import 'package:luxlog/features/portfolio/presentation/portfolio_screen.dart';
import 'package:luxlog/features/portfolio/presentation/portfolio_editor_screen.dart';
import 'package:luxlog/features/portfolio/presentation/public_portfolio_screen.dart';
import 'package:luxlog/features/profile/presentation/profile_screen.dart';
import 'package:luxlog/features/explore/presentation/explore_screen.dart';
import 'package:luxlog/features/notifications/presentation/notifications_screen.dart';
import 'package:luxlog/features/tags/presentation/tag_feed_screen.dart';
import 'package:luxlog/shared/widgets/main_scaffold.dart';

import 'package:luxlog/core/services/supabase_service.dart';

final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final session = SupabaseService.client.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    // Only redirect: if already logged in and visiting auth pages → go home
    if (session != null && isLoggingIn) {
      return '/';
    }

    // Protected routes: require auth for upload, profile edit, notifications
    const protectedPrefixes = ['/upload', '/notifications'];
    final isProtected = protectedPrefixes.any((p) => state.matchedLocation.startsWith(p));
    if (session == null && isProtected) {
      return '/login';
    }

    return null;
  },
  routes: [
    // ── Auth ────────────────────────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
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

        // User Profile (own profile from bottom nav)
        GoRoute(
          path: '/profile',
          name: 'my-profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(username: 'me'),
          ),
        ),

        // User Profile (other users)
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

    // ── Notifications ─────────────────────────────────────────
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ── Public Portfolio ──────────────────────────────────────
    GoRoute(
      path: '/p/:slug',
      name: 'public-portfolio',
      builder: (context, state) => PublicPortfolioScreen(
        slug: state.pathParameters['slug']!,
      ),
    ),

    // ── Tag Feed ──────────────────────────────────────────────
    GoRoute(
      path: '/tag/:tagName',
      name: 'tag-feed',
      builder: (context, state) => TagFeedScreen(
        tagName: state.pathParameters['tagName']!,
      ),
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
