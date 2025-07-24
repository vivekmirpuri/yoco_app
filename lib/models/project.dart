import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String? id;
  final String name;
  final String description;
  final String userId;
  final String status;
  final List<String> tags;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? thumbnailUrl;
  final int assetCount;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.userId,
    this.status = 'active',
    this.tags = const [],
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    this.thumbnailUrl,
    this.assetCount = 0,
  });

  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'active',
      tags: List<String>.from(map['tags'] ?? []),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      thumbnailUrl: map['thumbnailUrl'],
      assetCount: map['assetCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'userId': userId,
      'status': status,
      'tags': tags,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'thumbnailUrl': thumbnailUrl,
      'assetCount': assetCount,
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    String? status,
    List<String>? tags,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? thumbnailUrl,
    int? assetCount,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      assetCount: assetCount ?? this.assetCount,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, description: $description, userId: $userId, status: $status, tags: $tags, settings: $settings, createdAt: $createdAt, updatedAt: $updatedAt, thumbnailUrl: $thumbnailUrl, assetCount: $assetCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.userId == userId &&
        other.status == status &&
        other.tags == tags &&
        other.settings == settings &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.thumbnailUrl == thumbnailUrl &&
        other.assetCount == assetCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        userId.hashCode ^
        status.hashCode ^
        tags.hashCode ^
        settings.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        thumbnailUrl.hashCode ^
        assetCount.hashCode;
  }
} 