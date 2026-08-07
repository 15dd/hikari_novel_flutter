enum Wenku8Node { wwwWenku8Net, wwwWenku8Cc }

extension Wenku8NodeDesc on Wenku8Node {
  String get node => ["https://www.wenku8.net", "https://www.wenku8.cc"][index];
}
