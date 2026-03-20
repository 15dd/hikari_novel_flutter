import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/photo/controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../network/request.dart';

class PhotoPage extends StatelessWidget {
  PhotoPage({super.key});

  final controller = Get.put(PhotoController());

  final RxInt currentIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton.filledTonal(onPressed: Get.back, icon: Icon(Icons.close, size: 30, color: Theme.of(context).colorScheme.primary)),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body:
          Get.arguments["gallery_mode"]
              ? Stack(
                children: [
                  PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    itemCount: Get.arguments["list"].length,
                    builder: (_, index) {
                      return PhotoViewGalleryPageOptions(imageProvider: CachedNetworkImageProvider(Get.arguments["list"][index], headers: Request.userAgent));
                    },
                    loadingBuilder:
                        (context, progress) => Center(
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress == null ? null : progress.cumulativeBytesLoaded / (progress.expectedTotalBytes?.toInt() ?? 0),
                            ),
                          ),
                        ),
                    pageController: controller.pageController,
                    onPageChanged: (index) => currentIndex.value = index,
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.all(20.0),
                      child: Obx(
                        () => Text(
                          "${currentIndex.value + 1} / ${Get.arguments["list"].length}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6), //阴影颜色
                                offset: Offset(1, 1), //阴影偏移量
                                blurRadius: 6, //模糊程度
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
              : PhotoView(
                imageProvider: CachedNetworkImageProvider(Get.arguments["url"], headers: Request.userAgent),
                loadingBuilder:
                    (context, progress) => Center(
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress == null ? null : progress.cumulativeBytesLoaded / (progress.expectedTotalBytes?.toInt() ?? 0),
                        ),
                      ),
                    ),
              ),
    );
  }
}
