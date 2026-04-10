import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? imageUrl;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [uid, email, displayName, imageUrl];
}
