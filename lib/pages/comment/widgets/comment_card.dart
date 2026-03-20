import 'package:flutter/material.dart';
import 'package:hikari_novel_flutter/common/common_widgets.dart';
import 'package:hikari_novel_flutter/models/comment_item.dart';
import 'package:hikari_novel_flutter/router/app_sub_router.dart';

import '../../../common/constants.dart';

class CommentCard extends StatelessWidget {
  final String aid;
  final CommentItem item;

  const CommentCard({super.key,required this.aid, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => AppSubRouter.toReply(aid: aid, rid: item.rid),
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
                        child: Text(
                          item.userName,
                          style: kCommentAndReplyUsernameTextStyle,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(Icons.keyboard_arrow_right_outlined)
                  ],
                ),
                const SizedBox(height: 18),
                Align(alignment: Alignment.centerLeft, child: Text(item.content, style: const TextStyle(fontSize: 15))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(item.time, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const Expanded(child: SizedBox()),
                    Row(
                      children: [
                        Icon(Icons.message_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(item.replyCount, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const Text("  "),
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(item.viewCount, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
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
