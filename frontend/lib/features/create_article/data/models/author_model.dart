import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/author_entity.dart';
import '../../../../features/auth/domain/entities/auth_user.dart';

class AuthorModel extends Equatable {
  const AuthorModel({
    required this.uid,
    required this.nameToDisplay,
    required this.biografy,
    required this.image,
    required this.articles,
    this.username,
    this.email,
    this.createdAt,
    this.totalViews = 0,
    this.lastActiveAt,
  });

  final String uid;
  final String? username;
  final String nameToDisplay;
  final String? email;
  final String biografy;
  final String image;
  final List<String> articles;
  final DateTime? createdAt;
  final int totalViews;
  final DateTime? lastActiveAt;

  factory AuthorModel.fromAuthUser(AuthUser authUser) {
    final nameToDisplay = authUser.displayName ??
        (authUser.email != null && authUser.email!.isNotEmpty
            ? authUser.email!.split('@').first
            : 'Author');

    return AuthorModel(
      uid: authUser.uid,
      username: nameToDisplay,
      nameToDisplay: nameToDisplay,
      email: authUser.email,
      biografy: '',
      image: authUser.imageUrl ?? '',
      articles: const [],
      totalViews: 0,
    );
  }

  factory AuthorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Author document ${snapshot.id} has no data');
    }
    return AuthorModel.fromMap(data, documentId: snapshot.id);
  }

  factory AuthorModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final uid = (map['uid'] as String?) ?? documentId ?? '';
    return AuthorModel(
      uid: uid,
      username: map['username'] as String?,
      nameToDisplay: map['nameToDisplay'] as String? ?? '',
      email: map['email'] as String?,
      biografy: map['biografy'] as String? ?? '',
      image: map['image'] as String? ?? '',
      articles: (map['articles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: _timestampToDateTime(map['createdAt']),
      totalViews: (map['totalViews'] as num?)?.toInt() ?? 0,
      lastActiveAt: _timestampToDateTime(map['lastActiveAt']),
    );
  }

  /// Payload for first-time `set` on Firestore (server timestamps for date fields).
  Map<String, dynamic> toFirestoreCreateMap() {
    return {
      'uid': uid,
      'username': username,
      'nameToDisplay': nameToDisplay,
      'email': email,
      'biografy': biografy,
      'image': image,
      'articles': articles,
      'createdAt': FieldValue.serverTimestamp(),
      'totalViews': totalViews,
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
  }

  /// Fields updated on each login when the document already exists.
  static Map<String, dynamic> loginUpdateFirestoreMap() {
    return {
      'lastActiveAt': FieldValue.serverTimestamp(),
    };
  }

  AuthorEntity toEntity() {
    return AuthorEntity(
      uid: uid,
      username: username,
      nameToDisplay: nameToDisplay,
      email: email,
      biografy: biografy,
      image: image,
      articles: articles,
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      totalViews: totalViews,
      lastActiveAt: lastActiveAt,
    );
  }

  static DateTime? _timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  List<Object?> get props => [
        uid,
        username,
        nameToDisplay,
        email,
        biografy,
        image,
        articles,
        createdAt,
        totalViews,
        lastActiveAt,
      ];
}
