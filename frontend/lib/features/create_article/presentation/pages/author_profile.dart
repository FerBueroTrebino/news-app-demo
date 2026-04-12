import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../widgets/author_article_tile.dart';
import '../../../../../injection_container.dart';
import '../bloc/author_profile/author_profile_cubit.dart';
import '../../../../../features/auth/presentation/bloc/auth/auth_cubit.dart';

class AuthorProfile extends StatelessWidget {
  const AuthorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated || authState.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My articles'),
        ),
        body: const Center(
          child: Text('Sign in to view your articles.'),
        ),
      );
    }

    final authorUid = authState.user!.uid;

    return BlocProvider(
      create: (_) => sl<AuthorProfileCubit>()..loadAuthorArticles(authorUid),
      child: const _AuthorArticlesBody(),
    );
  }
}

class _AuthorArticlesBody extends StatelessWidget {
  const _AuthorArticlesBody();

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My articles'),
      ),
      body: BlocBuilder<AuthorProfileCubit, AuthorProfileState>(
        builder: (context, state) {
          switch (state.authorArticlesStatus) {
            case AuthorArticlesListStatus.initial:
            case AuthorArticlesListStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AuthorArticlesListStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.authorArticlesError ?? 'Something went wrong.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          final auth = context.read<AuthCubit>().state;
                          if (auth is Authenticated && auth.user != null) {
                            context
                                .read<AuthorProfileCubit>()
                                .loadAuthorArticles(auth.user!.uid);
                          }
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            case AuthorArticlesListStatus.success:
              break;
          }

          if (state.authorArticles.isEmpty) {
            return Center(
              child: Text(
                'No articles yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: state.authorArticles.length,
            itemBuilder: (context, index) {
              final article = state.authorArticles[index];
              return AuthorArticleTile(
                article: article,
                dateFormat: dateFormat,
              );
            },
          );
        },
      ),
    );
  }
}
