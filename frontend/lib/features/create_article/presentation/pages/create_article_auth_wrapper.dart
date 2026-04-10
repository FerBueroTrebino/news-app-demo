import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:news_app_clean_architecture/injection_container.dart';

import 'sign_in_screen.dart';
import 'create_article_screen.dart';
import '../bloc/create_article/create_article_cubit.dart';
import '../widgets/app_bar_create_article.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_cubit.dart';

class CreateArticleAuthWrapper extends StatelessWidget {
  const CreateArticleAuthWrapper({super.key});

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
            return BlocProvider(
              create: (_) => sl<CreateArticleCubit>(),
              child: const CreateArticleScreen(),
            );
          }

          return SignInScreen();
        },
      ),
    );
  }
}
