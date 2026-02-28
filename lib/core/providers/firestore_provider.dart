import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incampus/models/event_model.dart';
import 'package:incampus/services/firestore_service.dart';

// Firestore service provider
final firestoreServiceProvider = Provider((ref) => FirestoreService());

// Get all events provider
final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getAllEvents();
});

// Get events stream provider
final eventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getEventsStream();
});

// Get single event provider
final eventProvider =
    FutureProvider.family<EventModel?, String>((ref, eventId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getEventById(eventId);
});

// Create event provider
final createEventProvider =
    FutureProvider.family<String, EventModel>((ref, event) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.createEvent(event);
});

// Update event provider
final updateEventProvider = FutureProvider.family<void, UpdateEventParams>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  await firestoreService.updateEvent(params.eventId, params.event);
});

// Delete event provider
final deleteEventProvider =
    FutureProvider.family<void, String>((ref, eventId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  await firestoreService.deleteEvent(eventId);
});

// Search events provider
final searchEventsProvider =
    FutureProvider.family<List<EventModel>, String>((ref, query) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.searchEvents(query);
});

// Get events by tag provider
final eventsByTagProvider =
    FutureProvider.family<List<EventModel>, String>((ref, tag) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getEventsByTag(tag);
});

// User subscriptions providers
// older future-based provider retained for one-off fetches if needed.
final userSubscriptionsProvider =
    FutureProvider.family<List<EventModel>, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUserSubscriptions(userId);
});

// stream-based provider for real-time updates on user's subscriptions
final userSubscriptionsStreamProvider =
    StreamProvider.family<List<EventModel>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserSubscriptionsStream(userId);
});

// Check subscription provider
final isUserSubscribedProvider =
    FutureProvider.family<bool, SubscriptionCheckParams>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.isUserSubscribed(params.userId, params.eventId);
});

// Subscribe to event provider
final subscribeEventProvider =
    FutureProvider.family<void, SubscriptionParams>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  await firestoreService.subscribeToEvent(params.userId, params.eventId);
});

// Unsubscribe from event provider
final unsubscribeEventProvider =
    FutureProvider.family<void, SubscriptionParams>((ref, params) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  await firestoreService.unsubscribeFromEvent(params.userId, params.eventId);
});

// Parameter classes
class UpdateEventParams {
  final String eventId;
  final EventModel event;

  UpdateEventParams({
    required this.eventId,
    required this.event,
  });
}

class SubscriptionParams {
  final String userId;
  final String eventId;

  SubscriptionParams({
    required this.userId,
    required this.eventId,
  });
}

class SubscriptionCheckParams {
  final String userId;
  final String eventId;

  SubscriptionCheckParams({
    required this.userId,
    required this.eventId,
  });
}
