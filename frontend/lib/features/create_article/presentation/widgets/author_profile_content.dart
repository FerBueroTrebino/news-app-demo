import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'author_article_tile.dart';
import '../../domain/entities/article_news_entity.dart';
import '../bloc/author_profile/author_profile_cubit.dart';
import '../../../../../features/auth/presentation/bloc/auth/auth_cubit.dart';

class AuthorProfileContent extends StatelessWidget {
  const AuthorProfileContent({
    super.key,
    required this.dateFormat,
    required this.onArticleTap,
  });

  final DateFormat dateFormat;
  final ValueChanged<ArticleNewsEntity> onArticleTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorProfileCubit, AuthorProfileState>(
      builder: (context, state) {
        switch (state.authorArticlesStatus) {
          case AuthorArticlesListStatus.initial:
          case AuthorArticlesListStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case AuthorArticlesListStatus.failure:
            return const _AuthorArticlesFailureView();
          case AuthorArticlesListStatus.success:
            break;
        }

        if (state.authorArticles.isEmpty) {
          return const _AuthorArticlesEmptyView();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: state.authorArticles.length,
          itemBuilder: (context, index) {
            final article = state.authorArticles[index];
            return AuthorArticleTile(
              article: article,
              dateFormat: dateFormat,
              onTap: () => onArticleTap(article),
            );
          },
        );
      },
    );
  }
}

class _AuthorArticlesFailureView extends StatelessWidget {
  const _AuthorArticlesFailureView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthorProfileCubit>().state;
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
  }
}

class _AuthorArticlesEmptyView extends StatelessWidget {
  const _AuthorArticlesEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No articles yet.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
