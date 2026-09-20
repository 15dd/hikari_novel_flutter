import 'package:flutter/material.dart';
import 'package:hikari_novel_flutter/models/recommend_block.dart';
import 'package:hikari_novel_flutter/widgets/novel_cover_card.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class RecommendBlockView extends StatelessWidget {
  const RecommendBlockView({super.key, required this.block});

  final RecommendBlock block;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.fromLTRB(6, 0, 0, 0),
          child: Text(
            block.title,
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        ResponsiveGridList(
          listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
          minItemWidth: 100,
          horizontalGridSpacing: 4,
          verticalGridSpacing: 4,
          children: block.list.map((item) {
            return NovelCoverCard(novelCover: item);
          }).toList(),
        ),
      ],
    );
  }
}
