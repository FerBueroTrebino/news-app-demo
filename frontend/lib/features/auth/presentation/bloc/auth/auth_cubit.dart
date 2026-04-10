import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../features/auth/domain/usecases/sign_out.dart';
import '../../../../../features/auth/domain/entities/auth_user.dart';
import '../../../../../features/auth/domain/usecases/get_current_user.dart';
import '../../../../../features/auth/domain/usecases/sign_in_with_google.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthCubit(
    this._getCurrentUserUseCase,
    this._signInWithGoogleUseCase,
    this._signOutUseCase,
  ) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    final user = await _getCurrentUserUseCase();
    if (user == null) {
      emit(const Unauthenticated());
      return;
    }

    emit(Authenticated(user));
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await _signInWithGoogleUseCase();
      if (user == null) {
        emit(const Unauthenticated(
            errorMessage: 'Google sign-in was cancelled.'));
        return;
      }
      emit(Authenticated(user));
    } catch (e) {
      emit(
        const Unauthenticated(
          errorMessage: 'Could not sign in with Google. Please try again.',
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _signOutUseCase();
      emit(const Unauthenticated());
    } catch (_) {
      emit(
        const Unauthenticated(
          errorMessage: 'Could not sign out. Please try again.',
        ),
      );
    }
  }
}
