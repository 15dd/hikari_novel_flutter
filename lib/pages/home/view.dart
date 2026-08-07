import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hikari_novel_flutter/pages/category/view.dart';
import 'package:hikari_novel_flutter/pages/completion/view.dart';
import 'package:hikari_novel_flutter/pages/home/controller.dart';
import 'package:hikari_novel_flutter/pages/ranking/view.dart';
import 'package:hikari_novel_flutter/pages/recommend/view.dart';
import 'package:hikari_novel_flutter/router/app_sub_router.dart';

class HomePage extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TabBar(
          tabs: controller.tabs.map((e) => Tab(text: e)).toList(),
          controller: controller.tabController,
          dividerHeight: 0,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
        ),
        titleSpacing: 0,
        actions: [IconButton(onPressed: () => AppSubRouter.toSearch(author: null), icon: Icon(Icons.search))],
      ),
      body: TabBarView(controller: controller.tabController, children: [RecommendView(), CategoryView(), RankingView(), CompletionView()]),
    );
  }
}
