import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hikari_novel_flutter/common/constants.dart';
import 'package:hikari_novel_flutter/common/util.dart';

import '../../../models/browsing_history.dart';
import '../../../network/request.dart';

class BrowsingHistoryCard extends StatelessWidget {
  final BrowsingHistory vh;
  final Function() onTap;
  final Function() onDelete;

  const BrowsingHistoryCard({super.key, required this.vh, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
        child: Row(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardBorderRadius)),
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 100,
                child: AspectRatio(
                  aspectRatio: 9 / 13,
                  child: CachedNetworkImage(
                    imageUrl: vh.img,
                    httpHeaders: Request.userAgent,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                    errorWidget: (context, url, error) => Column(children: [const Icon(Icons.error_outline), Text(error.toString())]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vh.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    SizedBox(height: 6),
                    Text(Util.getDateTime(vh.time.toString().split('.').first), style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Center(
              child: IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
            ),
          ],
        ),
      ),
    );
  }
}
