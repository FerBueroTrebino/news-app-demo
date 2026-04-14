import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/routes.dart';
import '../../../auth/presentation/bloc/auth/auth_cubit.dart';

class AppBarCreateArticle extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarCreateArticle({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Create News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is! Authenticated) {
              return const SizedBox.shrink();
            }

            return PopupMenuButton<_CreateArticleMenuAction>(
              icon: const Icon(Icons.menu),
              tooltip: 'Menu',
              onSelected: (action) {
                switch (action) {
                  case _CreateArticleMenuAction.myArticles:
                    Navigator.pushNamed(
                      context,
                      AppRouteName.authorProfile.path,
                    );
                    break;
                  case _CreateArticleMenuAction.logOut:
                    context.read<AuthCubit>().signOut();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<_CreateArticleMenuAction>(
                  value: _CreateArticleMenuAction.myArticles,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person),
                    title: Text('My Articles'),
                  ),
                ),
                PopupMenuItem<_CreateArticleMenuAction>(
                  value: _CreateArticleMenuAction.logOut,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout),
                    title: Text('Log Out'),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

enum _CreateArticleMenuAction {
  myArticles,
  logOut,
}
