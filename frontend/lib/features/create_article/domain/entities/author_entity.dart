import 'package:equatable/equatable.dart';

class AuthorEntity extends Equatable {
  final String uid;
  final String? username;
  final String nameToDisplay;
  final String? email;
  final String biografy;
  final String image;
  final List<String> articles;
  final DateTime createdAt;
  final int totalViews;
  final DateTime? lastActiveAt;

  const AuthorEntity({
    required this.uid,
    required this.nameToDisplay,
    required this.biografy,
    required this.image,
    required this.articles,
    required this.createdAt,
    this.username,
    this.email,
    this.totalViews = 0,
    this.lastActiveAt,
  });

  @override
  List<Object?> get props => [
        uid,
        nameToDisplay,
        biografy,
        image,
        articles,
        createdAt,
        username,
        email,
        totalViews,
        lastActiveAt,
      ];
}
