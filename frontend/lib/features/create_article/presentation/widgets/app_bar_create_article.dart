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

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, AppRouteName.authorProfile.path);
                  },
                  icon: const Icon(Icons.person),
                  tooltip: 'My articles',
                ),
                IconButton(
                  onPressed: () {
                    context.read<AuthCubit>().signOut();
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
