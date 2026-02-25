import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final String? imageUrl;
  final int capacity;
  final int attendees;
  final String organizerId;
  final String clubId;
  final String clubName;
  final String? clubLogoUrl;
  final List<String> tags;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.imageUrl,
    required this.capacity,
    required this.attendees,
    required this.organizerId,
    required this.clubId,
    required this.clubName,
    this.clubLogoUrl,
    required this.tags,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    // Use Firestore Timestamp for dates so that queries/sorting work reliably.
    return {
      'id': id,
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'imageUrl': imageUrl,
      'capacity': capacity,
      'attendees': attendees,
      'organizerId': organizerId,
      'clubId': clubId,
      'clubName': clubName,
      'clubLogoUrl': clubLogoUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String docId) {
    // Helper that converts various Firestore date representations into DateTime.
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue == null) {
        return DateTime.now(); // fallback, though value should exist
      }
      if (dateValue is DateTime) {
        return dateValue;
      }
      if (dateValue is String) {
        // stored as ISO string
        return DateTime.tryParse(dateValue) ?? DateTime.now();
      }
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }
      // Some web snapshots give maps with seconds/nanoseconds
      if (dateValue is Map) {
        if (dateValue.containsKey('_seconds') && dateValue.containsKey('_nanoseconds')) {
          final seconds = dateValue['_seconds'] as int;
          final nanos = dateValue['_nanoseconds'] as int;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000 + (nanos / 1000000).round());
        }
      }
      return DateTime.now();
    }

    return EventModel(
      id: docId,
      title: map['title'] as String,
      description: map['description'] as String,
      eventDate: parseDateTime(map['eventDate']),
      location: map['location'] as String,
      imageUrl: map['imageUrl'] as String?,
      capacity: map['capacity'] as int? ?? 0,
      attendees: map['attendees'] as int? ?? 0,
      organizerId: map['organizerId'] as String,
      clubId: map['clubId'] as String? ?? '',
      clubName: map['clubName'] as String? ?? 'Unknown Club',
      clubLogoUrl: map['clubLogoUrl'] as String?,
      tags: _parseTags(map['tags']),
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  static List<String> _parseTags(dynamic tagData) {
    if (tagData == null) return [];
    if (tagData is List) {
      return tagData.map((tag) => tag.toString()).toList();
    }
    return [];
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? imageUrl,
    int? capacity,
    int? attendees,
    String? organizerId,
    String? clubId,
    String? clubName,
    String? clubLogoUrl,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      capacity: capacity ?? this.capacity,
      attendees: attendees ?? this.attendees,
      organizerId: organizerId ?? this.organizerId,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      clubLogoUrl: clubLogoUrl ?? this.clubLogoUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, clubName: $clubName)';
  }
}
