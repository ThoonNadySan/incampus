class ClubModel {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? bannerUrl;
  final int memberCount;
  final DateTime createdAt;

  ClubModel({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.bannerUrl,
    required this.memberCount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClubModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue.runtimeType.toString() == '_Timestamp') {
        return dateValue.toDate() as DateTime;
      }
      return DateTime.now();
    }

    return ClubModel(
      id: docId,
      name: map['name'] as String,
      description: map['description'] as String,
      logoUrl: map['logoUrl'] as String?,
      bannerUrl: map['bannerUrl'] as String?,
      memberCount: map['memberCount'] as int? ?? 0,
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ClubModel(id: $id, name: $name)';
  }
}
