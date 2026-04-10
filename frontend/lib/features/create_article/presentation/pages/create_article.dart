import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/google_sign_in_button.dart';

class CreateArticle extends StatelessWidget {
  const CreateArticle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppbar(context),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is Authenticated) {
              return const Center(child: Text('Create News'));
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'You need to sign in to create an article.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    GoogleSignInButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthSignInWithGooglePressed(),
                            );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  AppBar _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Create News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [],
    );
  }
}
