import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incampus/models/event_model.dart';
import 'package:incampus/models/club_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection references
  static const String eventsCollection = 'events';
  static const String usersCollection = 'users';
  static const String subscriptionsCollection = 'subscriptions';
  static const String clubsCollection = 'clubs';
  static const String clubSubscriptionsCollection = 'clubSubscriptions';

  // ===== EVENTS =====

  /// Get all events
  Future<List<EventModel>> getAllEvents() async {
    try {
      final snapshot = await _db
          .collection(eventsCollection)
          .orderBy('eventDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events: $e');
    }
  }

  /// Get events stream (for real-time updates)
  Stream<List<EventModel>> getEventsStream() {
    return _db
        .collection(eventsCollection)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _db.collection(eventsCollection).doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  /// Create event
  Future<String> createEvent(EventModel event) async {
    try {
      final docRef = await _db.collection(eventsCollection).add(event.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Update event
  Future<void> updateEvent(String eventId, EventModel event) async {
    try {
      await _db
          .collection(eventsCollection)
          .doc(eventId)
          .update(event.toMap());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.collection(eventsCollection).doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Search events by title
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final snapshot = await _db
          .collection(eventsCollection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '$query' 'z')
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  /// Get events by tag
  Future<List<EventModel>> getEventsByTag(String tag) async {
    try {
      final snapshot = await _db
          .collection(eventsCollection)
          .where('tags', arrayContains: tag)
          .get();

      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events by tag: $e');
    }
  }

  // ===== USER SUBSCRIPTIONS =====

  /// Subscribe user to event
  Future<void> subscribeToEvent(String userId, String eventId) async {
    try {
      await _db
          .collection(usersCollection)
          .doc(userId)
          .collection(subscriptionsCollection)
          .doc(eventId)
          .set({
        'eventId': eventId,
        'subscribedAt': DateTime.now().toIso8601String(),
      });

      // Increment attendees count
      await _db.collection(eventsCollection).doc(eventId).update({
        'attendees': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to subscribe to event: $e');
    }
  }

  /// Unsubscribe user from event
  Future<void> unsubscribeFromEvent(String userId, String eventId) async {
    try {
      await _db
          .collection(usersCollection)
          .doc(userId)
          .collection(subscriptionsCollection)
          .doc(eventId)
          .delete();

      // Decrement attendees count
      await _db.collection(eventsCollection).doc(eventId).update({
        'attendees': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to unsubscribe from event: $e');
    }
  }

  /// Get user subscriptions (one-time fetch)
  Future<List<EventModel>> getUserSubscriptions(String userId) async {
    try {
      final subscriptions = await _db
          .collection(usersCollection)
          .doc(userId)
          .collection(subscriptionsCollection)
          .get();

      List<EventModel> events = [];
      for (var sub in subscriptions.docs) {
        final event = await getEventById(sub.data()['eventId']);
        if (event != null) {
          events.add(event);
        }
      }
      return events;
    } catch (e) {
      throw Exception('Failed to get user subscriptions: $e');
    }
  }

  /// Stream of user subscriptions so UI can react in real time
  Stream<List<EventModel>> getUserSubscriptionsStream(String userId) {
    // listen to the subscription documents and load the corresponding events
    return _db
        .collection(usersCollection)
        .doc(userId)
        .collection(subscriptionsCollection)
        .snapshots()
        .asyncMap((snapshot) async {
      final ids = snapshot.docs
          .map((d) => d.data()['eventId'] as String)
          .toList();
      final results = await Future.wait(ids.map((id) => getEventById(id)));
      return results.whereType<EventModel>().toList();
    });
  }

  /// Check if user is subscribed to event
  Future<bool> isUserSubscribed(String userId, String eventId) async {
    try {
      final doc = await _db
          .collection(usersCollection)
          .doc(userId)
          .collection(subscriptionsCollection)
          .doc(eventId)
          .get();

      return doc.exists;
    } catch (e) {
      throw Exception('Failed to check subscription: $e');
    }
  }

  // ===== BATCH OPERATIONS =====

  // ===== CLUBS =====

  /// Get all clubs
  Stream<List<ClubModel>> getAllClubs() {
    return _db
        .collection(clubsCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClubModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get club by ID
  Future<ClubModel?> getClubById(String clubId) async {
    try {
      final doc = await _db.collection(clubsCollection).doc(clubId).get();
      if (doc.exists) {
        return ClubModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get club: $e');
    }
  }

  /// Create club
  Future<String> createClub(ClubModel club) async {
    try {
      final docRef = await _db.collection(clubsCollection).add(club.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create club: $e');
    }
  }

  /// Update club
  Future<void> updateClub(String clubId, ClubModel club) async {
    try {
      await _db
          .collection(clubsCollection)
          .doc(clubId)
          .update(club.toMap());
    } catch (e) {
      throw Exception('Failed to update club: $e');
    }
  }

  /// Delete club
  Future<void> deleteClub(String clubId) async {
    try {
      await _db.collection(clubsCollection).doc(clubId).delete();
    } catch (e) {
      throw Exception('Failed to delete club: $e');
    }
  }

  /// Get user's subscribed club IDs
  Future<List<String>> getUserSubscribedClubIds(String userId) async {
    try {
      final doc = await _db
          .collection(usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final clubIds = doc.data()?['subscribedClubIds'] as List<dynamic>? ?? [];
        return clubIds.cast<String>();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get user club subscriptions: $e');
    }
  }

  /// Update user's club subscriptions
  Future<void> updateUserClubSubscriptions(
      String userId, List<String> clubIds) async {
    try {
      await _db
          .collection(usersCollection)
          .doc(userId)
          .update({
        'subscribedClubIds': clubIds,
      });
    } catch (e) {
      throw Exception('Failed to update club subscriptions: $e');
    }
  }

  // ===== BATCH OPERATIONS =====

  /// Create multiple events
  Future<void> createEventsBatch(List<EventModel> events) async {
    try {
      final batch = _db.batch();

      for (var event in events) {
        final docRef = _db.collection(eventsCollection).doc();
        batch.set(docRef, event.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create events batch: $e');
    }
  }

  /// Delete all events (use with caution!)
  Future<void> deleteAllEvents() async {
    try {
      final snapshot = await _db.collection(eventsCollection).get();
      final batch = _db.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all events: $e');
    }
  }
}
