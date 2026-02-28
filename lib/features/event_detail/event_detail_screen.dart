import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incampus/core/providers/auth_provider.dart';
import 'package:incampus/core/providers/firestore_provider.dart';
import 'package:incampus/core/theme/app_theme.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late bool _isSubscribed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      final isSubscribed = await ref.read(
        isUserSubscribedProvider(
          SubscriptionCheckParams(
            userId: currentUser.uid,
            eventId: widget.eventId,
          ),
        ).future,
      );
      setState(() {
        _isSubscribed = isSubscribed;
      });
    }
  }

  Future<void> _toggleSubscription() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSubscribed) {
        await ref.read(
          unsubscribeEventProvider(
            SubscriptionParams(
              userId: currentUser.uid,
              eventId: widget.eventId,
            ),
          ).future,
        );
      } else {
        await ref.read(
          subscribeEventProvider(
            SubscriptionParams(
              userId: currentUser.uid,
              eventId: widget.eventId,
            ),
          ).future,
        );
      }

      setState(() {
        _isSubscribed = !_isSubscribed;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isSubscribed
                  ? 'Subscribed to event'
                  : 'Unsubscribed from event',
            ),
          ),
        );
      }

      // make sure any listeners on subscriptions update right away
      if (currentUser != null) {
        ref.invalidate(userSubscriptionsStreamProvider(currentUser.uid));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventProvider(widget.eventId));

    return Scaffold(
      body: eventAsync.when(
        data: (event) {
          if (event == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Event not found')),
              body: Center(
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
                        Icons.event_busy,
                        size: 64,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Event not found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            );
          }

          final attendancePercent = event.capacity > 0 ? event.attendees / event.capacity : 0.0;

          return CustomScrollView(
            slivers: [
              // Image Header with Back Button
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Event Image
                      event.imageUrl != null
                          ? Image.network(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholderImage();
                              },
                            )
                          : _buildPlaceholderImage(),
                      // Gradient Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Club Badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Text(
                            event.clubName.isNotEmpty ? event.clubName : 'Event',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.background,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              event.title,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Tags
                            if (event.tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  ...event.tags.map((tag) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.secondary,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        tag,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            const SizedBox(height: 24),
                            // Info Cards
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow(
                                    context,
                                    Icons.calendar_today_outlined,
                                    'Date & Time',
                                    _formatDate(event.eventDate),
                                  ),
                                  Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: AppColors.border,
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.location_on_outlined,
                                    'Location',
                                    event.location,
                                  ),
                                  Divider(
                                    height: 1,
                                    indent: 16,
                                    endIndent: 16,
                                    color: AppColors.border,
                                  ),
                                  _buildInfoRow(
                                    context,
                                    Icons.people_outlined,
                                    'Attendance',
                                    '${event.attendees}/${event.capacity} attending',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Attendance Progress
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Event Capacity',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Seats filled',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${(attendancePercent * 100).toStringAsFixed(0)}%',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: attendancePercent.clamp(0.0, 1.0),
                                    minHeight: 8,
                                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      attendancePercent > 0.9
                                          ? AppColors.error
                                          : attendancePercent > 0.7
                                              ? AppColors.warning
                                              : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Description
                            Text(
                              'About this event',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              event.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textLight,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Subscribe Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _toggleSubscription,
                                icon: Icon(
                                  _isSubscribed ? Icons.bookmark : Icons.bookmark_outline,
                                ),
                                label: Text(
                                  _isSubscribed ? 'Remove from Subscriptions' : 'Subscribe to Event',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: _isSubscribed ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Scaffold(
          appBar: AppBar(
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                onPressed: () => context.pop(),
              ),
            ),
          ),
          body: Center(
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
                  'Error loading event',
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
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
