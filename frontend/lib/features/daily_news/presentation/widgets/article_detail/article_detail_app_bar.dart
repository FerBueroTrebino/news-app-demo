import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ArticleDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPressed;

  const ArticleDetailAppBar({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onBackPressed,
        child: Icon(
          Ionicons.chevron_back,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
