import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/sign_in_screen.dart';
import '../widgets/app_bar_create_article.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_cubit.dart';

class CreateArticle extends StatelessWidget {
  const CreateArticle({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCreateArticle(),
      body: BlocConsumer<AuthCubit, AuthState>(
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

          return SignInScreen();
        },
      ),
    );
  }
}
