// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../providers/category_provider.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/common/gradient_header.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/flashcard/flashcard_tile.dart';
import '../../utils/extensions.dart';
import '../flashcards/add_edit_flashcard_screen.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 👋';
    return 'Good Evening! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final cardProvider = context.watch<FlashcardProvider>();
    final statsProvider = context.watch<StatsProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final role = user?.role ?? 'Student';
    final isAdmin = role == 'Admin';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            catProvider.loadCategories(),
            cardProvider.loadFlashcards(userId: user?.id),
            statsProvider.loadStats(userId: user?.id, role: role),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: GradientHeader(
                child: Stack(
                  children: [
                    Positioned.fill(child: const HeaderDecoration()),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.lg,
                        MediaQuery.of(context).padding.top + AppSizes.lg,
                        AppSizes.lg,
                        AppSizes.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _greeting(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isAdmin ? 'Admin Dashboard' : 'Ready to Study?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateTime.now().formattedDate,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Avatar / notification icon
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.3)),
                                ),
                                child: const Icon(Icons.notifications_outlined,
                                    color: Colors.white, size: 22),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          // Search bar
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/search'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusFull),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.25)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 18),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Search flashcards...',
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats row (pulled up to overlap header)
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: StatsRow(cards: [
                  StatCard(
                    title: 'Total Cards',
                    value: '${cardProvider.totalCount}',
                    icon: Icons.style_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.pushNamed(context, '/flashcards'),
                  ),
                  StatCard(
                    title: 'Categories',
                    value: '${catProvider.count}',
                    icon: Icons.category_rounded,
                    color: AppColors.accent,
                    onTap: () => Navigator.pushNamed(context, '/categories'),
                  ),
                  if (isAdmin) ...[
                    StatCard(
                      title: 'Total Studied',
                      value: '${statsProvider.totalStudied}',
                      icon: Icons.done_all_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () => Navigator.pushNamed(context, '/statistics'),
                    ),
                    StatCard(
                      title: 'Sessions',
                      value: '${statsProvider.totalSessions}',
                      icon: Icons.assignment_turned_in_rounded,
                      color: const Color(0xFFEF4444),
                      onTap: () => Navigator.pushNamed(context, '/statistics'),
                    ),
                  ] else ...[
                    StatCard(
                      title: "Today's Study",
                      value: '${statsProvider.todayStudied}',
                      icon: Icons.today_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () => Navigator.pushNamed(context, '/statistics'),
                    ),
                    StatCard(
                      title: 'Streak',
                      value: '${statsProvider.studyStreak}d',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFEF4444),
                      subtitle: 'Keep it up!',
                      onTap: () => Navigator.pushNamed(context, '/statistics'),
                    ),
                  ]
                ]),
              ),
            ),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSizes.md, 0, AppSizes.md, AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: AppSizes.sm),
                    _QuickActionsGrid(),
                    const SizedBox(height: AppSizes.lg),
                    _SectionHeader(
                      title: 'Recent Flashcards',
                      actionLabel: 'View All',
                      onAction: () => Navigator.pushNamed(context, '/flashcards'),
                    ),
                  ],
                ),
              ),
            ),

            // Recent flashcards
            cardProvider.recent.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Center(
                        child: Text(
                          'No flashcards yet. Add your first one!',
                          style: GoogleFonts.inter(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final card = cardProvider.recent[index];
                        return FlashcardTile(
                          card: card,
                          accentColor: catProvider
                              .getById(card.categoryId)
                              ?.color,
                          onFavorite: () =>
                              cardProvider.toggleFavorite(card.id, userId: user?.id),
                          onTap: () => Navigator.pushNamed(
                              context, '/study',
                              arguments: card.categoryId),
                        );
                      },
                      childCount: cardProvider.recent.length,
                    ),
                  ),

            const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSizes.xxl + AppSizes.lg)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditFlashcardScreen()),
        ),
        child: const Icon(Icons.add_rounded),
        tooltip: 'Add Flashcard',
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().currentUser?.role ?? 'Student';
    final List<_QuickAction> actions;

    if (role == 'Admin') {
      actions = const [
        _QuickAction(
          icon: Icons.category_rounded,
          label: 'Categories',
          color: Color(0xFF7C3AED),
          route: '/categories',
        ),
        _QuickAction(
          icon: Icons.style_rounded,
          label: 'Cards',
          color: AppColors.primary,
          route: '/flashcards',
        ),
        _QuickAction(
          icon: Icons.bar_chart_rounded,
          label: 'Stats',
          color: AppColors.accent,
          route: '/statistics',
        ),
        _QuickAction(
          icon: Icons.settings_rounded,
          label: 'Settings',
          color: Color(0xFFDB2777),
          route: '/settings',
        ),
      ];
    } else {
      actions = const [
        _QuickAction(
          icon: Icons.menu_book_rounded,
          label: 'Study',
          color: AppColors.primary,
          route: '/study',
        ),
        _QuickAction(
          icon: Icons.quiz_rounded,
          label: 'Quiz',
          color: AppColors.accent,
          route: '/quiz',
        ),
        _QuickAction(
          icon: Icons.category_rounded,
          label: 'Categories',
          color: Color(0xFF7C3AED),
          route: '/categories',
        ),
        _QuickAction(
          icon: Icons.favorite_rounded,
          label: 'Favorites',
          color: Color(0xFFDB2777),
          route: '/favorites',
        ),
      ];
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.sm,
      crossAxisSpacing: AppSizes.sm,
      childAspectRatio: 0.85,
      children: actions
          .map((a) => _QuickActionCard(action: a))
          .toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.route});
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, action.route),
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: action.color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
