import 'package:get/get.dart';
import 'package:hikari_novel_flutter/models/common/wenku8_node.dart';
import 'package:hikari_novel_flutter/service/local_storage_service.dart';

class WelcomeController extends GetxController {
  Wenku8Node wenku8Node = LocalStorageService.instance.getWenku8Node();

  void changeWenku8Node(Wenku8Node n) {
    wenku8Node = n;
    LocalStorageService.instance.setWenku8Node(n);
  }
}
