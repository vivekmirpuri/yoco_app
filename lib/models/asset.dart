import 'package:cloud_firestore/cloud_firestore.dart';

class Asset {
  final String? id;
  final String name;
  final String type;
  final String projectId;
  final String userId;
  final String url;
  final String? thumbnailUrl;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int fileSize;
  final String? mimeType;

  Asset({
    this.id,
    required this.name,
    required this.type,
    required this.projectId,
    required this.userId,
    required this.url,
    this.thumbnailUrl,
    this.metadata = const {},
    this.tags = const [],
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.fileSize = 0,
    this.mimeType,
  });

  factory Asset.fromMap(Map<String, dynamic> map, String id) {
    return Asset(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      projectId: map['projectId'] ?? '',
      userId: map['userId'] ?? '',
      url: map['url'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      tags: List<String>.from(map['tags'] ?? []),
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      fileSize: map['fileSize'] ?? 0,
      mimeType: map['mimeType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'projectId': projectId,
      'userId': userId,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'metadata': metadata,
      'tags': tags,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'fileSize': fileSize,
      'mimeType': mimeType,
    };
  }

  Asset copyWith({
    String? id,
    String? name,
    String? type,
    String? projectId,
    String? userId,
    String? url,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? fileSize,
    String? mimeType,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  bool get isImage => type.toLowerCase().contains('image');
  bool get isVideo => type.toLowerCase().contains('video');
  bool get isAudio => type.toLowerCase().contains('audio');
  bool get isDocument => type.toLowerCase().contains('document') || 
                        type.toLowerCase().contains('pdf') ||
                        type.toLowerCase().contains('text');

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  String toString() {
    return 'Asset(id: $id, name: $name, type: $type, projectId: $projectId, userId: $userId, url: $url, thumbnailUrl: $thumbnailUrl, metadata: $metadata, tags: $tags, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, fileSize: $fileSize, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Asset &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.projectId == projectId &&
        other.userId == userId &&
        other.url == url &&
        other.thumbnailUrl == thumbnailUrl &&
        other.metadata == metadata &&
        other.tags == tags &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        projectId.hashCode ^
        userId.hashCode ^
        url.hashCode ^
        thumbnailUrl.hashCode ^
        metadata.hashCode ^
        tags.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        fileSize.hashCode ^
        mimeType.hashCode;
  }
} 