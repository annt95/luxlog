import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/features/notifications/providers/notification_provider.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/feed')) return 1;
    if (location.startsWith('/portfolio')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _currentIndex(context);
    final user = ref.watch(currentUserProvider);
    final unreadCountAsync = user != null ? ref.watch(unreadNotificationCountProvider(user.id)) : const AsyncValue.data(0);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          child,
          // Glassmorphism bottom nav — Stitch "Obsidian Gold" redesign
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _GlassBottomNav(
              currentIndex: idx,
              unreadNotifications: unreadCount,
            ),
          ),
        ],
      ),
      floatingActionButton: _UploadFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final int unreadNotifications;
  const _GlassBottomNav({
    required this.currentIndex,
    required this.unreadNotifications,
  });

  /// 4 tabs: Discover, Feed, [FAB gap], Portfolio, Profile
  /// Symmetrical: 2 left + gap + 2 right
  static const _tabs = [
    (icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Discover', path: '/'),
    (icon: Icons.dynamic_feed_outlined, activeIcon: Icons.dynamic_feed, label: 'Feed', path: '/feed'),
    (icon: Icons.collections_outlined, activeIcon: Icons.collections, label: 'Portfolio', path: '/portfolio'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72 + bottomPadding,
          decoration: BoxDecoration(
            color: const Color(0xD90E0E0E), // rgba(14,14,14,0.85)
            border: const Border(
              top: BorderSide(
                color: Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              children: [
                // ── Left 2 tabs ──
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: currentIndex == 0 ? _tabs[0].activeIcon : _tabs[0].icon,
                        label: _tabs[0].label,
                        isActive: currentIndex == 0,
                        onTap: () => context.go(_tabs[0].path),
                      ),
                      _NavItem(
                        icon: currentIndex == 1 ? _tabs[1].activeIcon : _tabs[1].icon,
                        label: _tabs[1].label,
                        isActive: currentIndex == 1,
                        onTap: () => context.go(_tabs[1].path),
                      ),
                    ],
                  ),
                ),
                // ── Center gap for FAB ──
                const SizedBox(width: 64),
                // ── Right 2 tabs ──
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: currentIndex == 2 ? _tabs[2].activeIcon : _tabs[2].icon,
                        label: _tabs[2].label,
                        isActive: currentIndex == 2,
                        onTap: () => context.go(_tabs[2].path),
                      ),
                      _NavItem(
                        icon: currentIndex == 3 ? _tabs[3].activeIcon : _tabs[3].icon,
                        label: _tabs[3].label,
                        isActive: currentIndex == 3,
                        hasBadge: unreadNotifications > 0,
                        onTap: () => context.go(_tabs[3].path),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool hasBadge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label tab${isActive ? ', selected' : ''}${hasBadge ? ', has notifications' : ''}',
      selected: isActive,
      child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pill-shaped highlight behind icon (active state)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0x26E2C19B) // primary at 15%
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isActive
                        ? AppColors.primary
                        : const Color(0xFF757575), // muted gray
                    size: 22,
                  ),
                  if (hasBadge)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: isActive
                    ? AppColors.primary
                    : const Color(0xFF757575),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _UploadFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Upload photo',
      child: Tooltip(
        message: 'Upload photo',
        child: GestureDetector(
          onTap: () => context.push('/upload'),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE2C19B), Color(0xFFD3B38E)],
              ),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE2C19B).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Color(0xFF412C11), // onPrimary
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
