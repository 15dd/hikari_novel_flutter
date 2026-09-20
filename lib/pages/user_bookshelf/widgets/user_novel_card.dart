import 'package:flutter/material.dart';
import 'package:hikari_novel_flutter/models/novel_cover.dart';

import '../../../router/app_sub_router.dart';

class UserNovelCard extends StatelessWidget {
  final NovelCover novelCover;

  const UserNovelCard({super.key, required this.novelCover});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppSubRouter.toNovelDetail(aid: novelCover.aid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20), child: Text(novelCover.title)),
          const Divider(height: 1, thickness: 0.3),
        ],
      ),
    );
  }
}
