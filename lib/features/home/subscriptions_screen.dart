import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incampus/core/providers/auth_provider.dart';
import 'package:incampus/core/providers/firestore_provider.dart';
import 'package:incampus/core/theme/app_theme.dart';
import 'dart:ui';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen> {
  final List<String> _tabs = ['All', '#art', '#design', '#creative', '#tech', '#sports'];
  String _selectedTab = 'All';
  bool _isFiltering = false;

  void _onSelectTab(String tab) async {
    if (_selectedTab == tab) return;
    setState(() {
      _isFiltering = true;
    });
    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    setState(() {
      _selectedTab = tab;
      _isFiltering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // watch the real-time stream so changes appear instantly
    final subscriptionsAsync = ref.watch(userSubscriptionsStreamProvider(currentUser.uid));

    return subscriptionsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return _buildEmptyState(context);
        }

        // apply filter if selected
        final filterKey = _selectedTab == 'All' ? null : _selectedTab.replaceFirst('#', '');
        final displayedEvents = filterKey == null
            ? events
            : events.where((event) {
                try {
                  final tags = (event.tags as List).map((t) => t.toString().toLowerCase()).toList();
                  return tags.contains(filterKey.toLowerCase());
                } catch (_) {
                  return false;
                }
              }).toList();

        // stream provider updates automatically, but keep pull-to-refresh
        // to allow the user to manually reload if needed
        return RefreshIndicator(
          onRefresh: () async {
            // invalidate underlying future provider in case of issues
            ref.invalidate(userSubscriptionsStreamProvider(currentUser.uid));
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // header with blurred background hero
              SliverAppBar(
                expandedHeight: 200,
                pinned: false,
                backgroundColor: AppColors.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // blurred image placeholder (use first event image or gradient)
                      if (events.first.imageUrl != null)
                        Image.network(
                          events.first.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      // blur overlay
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(color: Colors.black.withOpacity(0.2)),
                      ),
                      // title & bookmark
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Subscriptions',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Events you\'ve bookmarked',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        right: 24,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: AppColors.accent.withOpacity(0.8),
                          onPressed: () {},
                          child: const Icon(Icons.bookmark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // tab bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabs.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tab = _tabs[index];
                        final selected = tab == _selectedTab;
                        return GestureDetector(
                          onTap: () => _onSelectTab(tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primaryDark : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(selected ? 0.12 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                tab,
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // events list
              SliverOpacity(
                opacity: _isFiltering ? 0.0 : 1.0,
                sliver: SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = displayedEvents[index];
                        return _buildSubscriptionCard(context, event);
                      },
                      childCount: displayedEvents.length,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading your subscriptions...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading subscriptions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPlaceholderImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.6), AppColors.secondary.withValues(alpha: 0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event,
          size: 64,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          expandedHeight: 160,
          backgroundColor: AppColors.background,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Subscriptions',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Events you\'ve bookmarked',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverFillRemaining(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.bookmark_outline,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No Subscriptions Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Start exploring events and bookmark the ones you\'re interested in!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to home feed - the parent will handle this
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('Browse Events'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, dynamic event) {
    final attendancePercent = event.capacity > 0 ? event.attendees / event.capacity : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.pushNamed('eventDetail', pathParameters: {'id': event.id});
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with gradient overlay (same as feed card)
                  Stack(
                    children: [
                      if (event.imageUrl != null)
                        Image.network(
                          event.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(180);
                          },
                        )
                      else
                        _buildPlaceholderImage(180),

                      // Gradient Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bookmark Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Content section
                  Container(
                    color: AppColors.cardBackground,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Location & Date
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.location,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(event.eventDate),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Attendance Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Attendance',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${event.attendees}/${event.capacity}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: attendancePercent.clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  attendancePercent > 0.8
                                      ? AppColors.warning
                                      : AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Past event';
    } else if (difference == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return '$difference days away';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
