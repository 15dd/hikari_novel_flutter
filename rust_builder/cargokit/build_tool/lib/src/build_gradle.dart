/// This is copied from Cargokit (which is the official way to use it currently)
/// Details: https://fzyzcjy.github.io/flutter_rust_bridge/manual/integrate/builtin

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'artifacts_provider.dart';
import 'builder.dart';
import 'environment.dart';
import 'options.dart';
import 'target.dart';

final log = Logger('build_gradle');

class BuildGradle {
  BuildGradle({required this.userOptions});

  final CargokitUserOptions userOptions;

  Future<void> build() async {
    final targets = Environment.targetPlatforms.map((arch) {
      final target = Target.forFlutterName(arch);
      if (target == null) {
        throw Exception(
            "Unknown darwin target or platform: $arch, ${Environment.darwinPlatformName}");
      }
      return target;
    }).toList();

    final environment = BuildEnvironment.fromEnvironment(isAndroid: true);
    final provider =
        ArtifactProvider(environment: environment, userOptions: userOptions);
    final artifacts = await provider.getArtifacts(targets);

    for (final target in targets) {
      final libs = artifacts[target]!;
      final outputDir = path.join(Environment.outputDir, target.android!);
      Directory(outputDir).createSync(recursive: true);

      for (final lib in libs) {
        if (lib.type == AritifactType.dylib) {
          File(lib.path).copySync(path.join(outputDir, lib.finalFileName));
        }
      }
      // BoringSSL 使用 c++_shared, 运行时还需要同目录下的 libc++_shared.so
      _copyCppShared(environment: environment, target: target, outputDir: outputDir);
    }
  }
}

// 从 NDK 复制 libc++_shared.so
void _copyCppShared({
  required BuildEnvironment environment,
  required Target target,
  required String outputDir,
}) {
  final sdkPath = environment.androidSdkPath;
  final ndkVersion = environment.androidNdkVersion;
  if (sdkPath == null || ndkVersion == null) {
    throw Exception('Android NDK location is not set');
  }
  // armeabi-v7a 在 sysroot 里的目录名是 arm-linux-androideabi。
  final triple = target.rust == 'armv7-linux-androideabi'
      ? 'arm-linux-androideabi'
      : target.rust;
  final hostArch = Platform.isMacOS
      ? 'darwin-x86_64'
      : (Platform.isLinux ? 'linux-x86_64' : 'windows-x86_64');
  final source = path.join(
    sdkPath,
    'ndk',
    ndkVersion,
    'toolchains/llvm/prebuilt',
    hostArch,
    'sysroot/usr/lib',
    triple,
    'libc++_shared.so',
  );
  if (!File(source).existsSync()) {
    throw Exception('libc++_shared.so not found at $source');
  }
  File(source).copySync(path.join(outputDir, 'libc++_shared.so'));
}
