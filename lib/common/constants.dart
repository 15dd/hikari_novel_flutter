import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String kAppName = "Hikari Novel";

const int kStatusBarPadding = 30;

const double kSmallIconSize = 16.0;

final TextStyle kBaseTileTitleTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);

final TextStyle kBaseTileSubtitleTextStyle = TextStyle(fontSize: 13);

const double kCardBorderRadius = 6.0;

const EdgeInsets kCommentAndReplyCardPadding = EdgeInsets.fromLTRB(20, 16, 20, 16);

final TextStyle kCommentAndReplyUsernameTextStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(Get.context!).colorScheme.primary);

const int kScrollReadMode = 1;

const int kPageReadMode = 2;