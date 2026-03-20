import 'package:flutter/material.dart';
import 'package:hikari_novel_flutter/common/common_widgets.dart';
import 'package:hikari_novel_flutter/models/reply_item.dart';

import '../../../common/constants.dart';
import '../../../router/app_sub_router.dart';

class ReplyCard extends StatelessWidget {
  final ReplyItem item;
  final int number;

  const ReplyCard({super.key, required this.item, required this.number});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => CommonWidgets.showCommentOrReplyBottomSheet(context, item.content),
      child: Column(
        children: [
          Padding(
            padding: kCommentAndReplyCardPadding,
            child: Column(
              children: [
                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => AppSubRouter.toUserBookshelf(uid: item.uid),
                        child: Text(item.userName, style: kCommentAndReplyUsernameTextStyle),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text("${number + 1}#", style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item.content, style: const TextStyle(fontSize: 15)),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(item.time, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.2),
        ],
      ),
    );
  }
}
