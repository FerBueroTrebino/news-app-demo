part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  final AuthUser? user;
  final String? errorMessage;

  const AuthState({this.user, this.errorMessage});

  @override
  List<Object?> get props => [user, errorMessage];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  const Authenticated(AuthUser user) : super(user: user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated({super.errorMessage});
}
