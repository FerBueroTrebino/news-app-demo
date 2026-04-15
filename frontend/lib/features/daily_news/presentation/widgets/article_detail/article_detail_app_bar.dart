import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ArticleDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBackPressed;
  final bool isReading;
  final VoidCallback onReadTogglePressed;

  const ArticleDetailAppBar({
    super.key,
    required this.onBackPressed,
    required this.isReading,
    required this.onReadTogglePressed,
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
      actions: [
        IconButton(
          onPressed: onReadTogglePressed,
          tooltip: isReading ? 'Stop reading' : 'Read article aloud',
          icon: Icon(isReading ? Icons.stop : Icons.headphones),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
