// lib/screens/statistics/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_sizes.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/charts/weekly_bar_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatsProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: provider.loadStats,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSizes.lg, AppSizes.lg, AppSizes.lg, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Track your learning progress',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: Text('Statistics',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 18)),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
            ),

            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.totalStudied == 0 && provider.totalSessions == 0)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.bar_chart_rounded,
                  title: 'No Statistics Yet',
                  description:
                      'Start studying and taking quizzes to see your progress here',
                  iconColor: const Color(0xFF0891B2),
                ),
              )
            else ...[
              // Summary cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle('Overview'),
                      const SizedBox(height: AppSizes.sm),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSizes.sm,
                        mainAxisSpacing: AppSizes.sm,
                        childAspectRatio: 1.5,
                        children: [
                          _OverviewCard(
                            title: 'Cards Studied',
                            value: '${provider.totalStudied}',
                            icon: Icons.style_rounded,
                            color: AppColors.primary,
                          ),
                          _OverviewCard(
                            title: 'Avg Accuracy',
                            value:
                                '${provider.averageAccuracy.toStringAsFixed(1)}%',
                            icon: Icons.track_changes_rounded,
                            color: AppColors.accent,
                          ),
                          _OverviewCard(
                            title: 'Study Streak',
                            value: '${provider.studyStreak} days',
                            icon: Icons.local_fire_department_rounded,
                            color: const Color(0xFFEF4444),
                          ),
                          _OverviewCard(
                            title: 'Best Score',
                            value:
                                '${provider.bestScore.toStringAsFixed(0)}%',
                            icon: Icons.emoji_events_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                          _OverviewCard(
                            title: "Today's Study",
                            value: '${provider.todayStudied}',
                            icon: Icons.today_rounded,
                            color: const Color(0xFF7C3AED),
                          ),
                          _OverviewCard(
                            title: 'Quiz Sessions',
                            value: '${provider.totalSessions}',
                            icon: Icons.quiz_rounded,
                            color: const Color(0xFF0891B2),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Weekly chart
                      _SectionTitle('Weekly Progress'),
                      const SizedBox(height: AppSizes.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusLG),
                          border: Border.all(
                              color: Theme.of(context).dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cards studied per day (last 7 days)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.55),
                              ),
                            ),
                            const SizedBox(height: AppSizes.md),
                            WeeklyBarChart(stats: provider.weeklyStats),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Recent quiz results
                      if (provider.recentResults.isNotEmpty) ...[
                        _SectionTitle('Recent Quiz Results'),
                        const SizedBox(height: AppSizes.sm),
                        ...provider.recentResults.map((result) {
                          final color = result.percentage >= 80
                              ? AppColors.success
                              : result.percentage >= 60
                                  ? AppColors.warning
                                  : AppColors.error;
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSizes.sm),
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              border: Border.all(
                                  color: Theme.of(context).dividerColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${result.percentage.toStringAsFixed(0)}%',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result.categoryName ?? 'All Categories',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${result.score}/${result.total} correct · ${result.durationFormatted}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  result.performanceMessage.split(' ').last,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],

            const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSizes.xxl + AppSizes.lg)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.55),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
