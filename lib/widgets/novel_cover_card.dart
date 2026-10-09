import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/models/bookshelf.dart';
import 'package:hikari_novel_flutter/models/novel_cover.dart';
import 'package:hikari_novel_flutter/router/app_sub_router.dart';

class NovelCoverCard extends StatelessWidget {
  final NovelCover novelCover;

  const NovelCoverCard({super.key, required this.novelCover});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(kCardBorderRadius),
      onTap: () => AppSubRouter.toNovelDetail(aid: novelCover.aid),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 9 / 13.5,
              child: CachedNetworkImage(
                imageUrl: novelCover.imageUrl!,
                httpHeaders: kUserAgent,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                errorWidget: (context, url, error) => Column(children: [Icon(Icons.error_outline), Text(error.toString())]),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter, // 渐变到图片一半
                    colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 1)],
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              width: double.infinity, //充满父组件宽度
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  novelCover.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookshelfCoverCard extends StatelessWidget {
  final BookshelfNovelInfo bookshelfNovelInfo;
  final Function() onTap;
  final Function() onLongPress;

  const BookshelfCoverCard({super.key, required this.bookshelfNovelInfo, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 9 / 13.5,
                  child: CachedNetworkImage(
                    imageUrl: bookshelfNovelInfo.img,
                    httpHeaders: kUserAgent,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => Column(children: [Icon(Icons.error_outline), Text(error.toString())]),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter, // 渐变到图片一半
                        colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 1)],
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  width: double.infinity, //充满父组件宽度
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      bookshelfNovelInfo.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Offstage(
              offstage: !bookshelfNovelInfo.isSelected.value,
              child: Container(
                decoration: ShapeDecoration(
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(kCardBorderRadius),
                    side: BorderSide(color: colorScheme.primary, width: 5),
                  ),
                  color: Colors.grey.withAlpha(128),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
