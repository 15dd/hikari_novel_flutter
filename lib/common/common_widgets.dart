import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/widgets/custom_tile.dart';

import '../pages/bookshelf/controller.dart';
import '../widgets/bottom_action_bar.dart';

//公共widget
class CommonWidgets {
  static Widget bookshelfBottomActionBar(BookshelfContentController currentTabController, BookshelfController bookshelfController, {bool edgeToEdge = false}) {
    return BottomActionBar(
      edgeToEdge: edgeToEdge,
      items: [
        BottomActionItem(
          icon: Icons.drive_file_move_outlined,
          label: "move_to_other_bookshelf".tr,
          onTap: () {
            Get.dialog(
              AlertDialog(
                title: Text("move_to_other_bookshelf".tr),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    6,
                    (i) => ListTile(
                      onTap: () async {
                        await currentTabController.moveNovelToOther(i);
                        currentTabController.exitSelectionMode();
                        Get.back(); //关闭dialog
                        await bookshelfController.refreshBookshelf();
                      },
                      title: Text("bookshelf_number_selection".trParams({"no": i.toString()})),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        BottomActionItem(
          icon: Icons.delete_outline_outlined,
          label: "remove_from_bookshelf".tr,
          onTap: () async {
            await currentTabController.removeNovelFromList();
            currentTabController.exitSelectionMode();
            await bookshelfController.refreshBookshelf();
          },
        ),
      ],
    );
  }

  static void showCommentOrReplyBottomSheet(BuildContext context, String content) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: Navigator.of(context).pop,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 35,
                  child: Center(
                    child: Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.outline, borderRadius: const BorderRadius.all(Radius.circular(3))),
                    ),
                  ),
                ),
              ),
              NormalTile(
                title: "copy_all".tr,
                leading: const Icon(Icons.copy_all_outlined, size: 19),
                onTap: () {
                  Navigator.of(context).pop();
                  Clipboard.setData(ClipboardData(text: content));
                },
              ),
              NormalTile(
                title: "free_copy".tr,
                leading: const Icon(Icons.copy_outlined, size: 19),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: Padding(
                        padding: const .symmetric(horizontal: 20, vertical: 16),
                        child: SelectableText(content, style: const TextStyle(fontSize: 15, height: 1.7)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      useSafeArea: true,
      isScrollControlled: true,
    );
  }
}
