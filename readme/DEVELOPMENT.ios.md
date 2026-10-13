## 开发环境

iOS 构建工具及流程的简单说明. 最低系统版本 iOS 13.0

### 工具链 (brew)

```bash
brew install cmake rustup-init nasm llvm cocoapods
brew install --cask flutter
rustup-init -y
rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios
```

- `cocoapods`: `rust_builder/ios/hikari_http.podspec` 的 script phase 会编出 `libhikari_http.a`
- `rustup target`: Cargokit 不会自动安装 target. 真机 `aarch64-apple-ios`, Apple Silicon 模拟器 `aarch64-apple-ios-sim`, Intel 模拟器 `x86_64-apple-ios`. podspec 已排除 i386

已经装过的跳过即可.

### 环境变量


| Key                        | Value                              |
| -------------------------- | ---------------------------------- |
| `LIBCLANG_PATH`            | `$(brew --prefix llvm)/lib`        |
| `FLUTTER_STORAGE_BASE_URL` | `https://storage.flutter-io.cn`    |
| `PUB_HOSTED_URL`           | `https://pub.flutter-io.cn`        |


写入 `~/.zshrc`:

```bash
export LIBCLANG_PATH="$(brew --prefix llvm)/lib"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
```

或临时在终端设置同一组 `export`.

- `LIBCLANG_PATH`：让 `bindgen` 找到 `libclang.dylib`.

---



## 常用命令



### 检查 Rust 网络层

确保 `rust` 桥接模块 `hikari_http` 能编过

```bash
cd hikari_novel_flutter/rust
cargo check
```



### 重新生成 Flutter 绑定

修改 `rust/src/api.rs` 对外接口后, 要重新生成胶水层

```bash
cargo install flutter_rust_bridge_codegen --version 2.11.1
cd hikari_novel_flutter
flutter_rust_bridge_codegen generate
```

codegen 版本与 pubspec.yaml 里的 flutter_rust_bridge: 2.11.1 对齐。

generate 命令读取当前目录的 `flutter_rust_bridge.yaml` (rust_root: rust/，dart_output: lib/src/rust)

不要手改 `lib/src/rust/frb_generated.dart` 和 `rust/src/frb_generated.rs`

### 构建 iOS

```bash
flutter clean
flutter pub get
flutter build ios --no-codesign

# 模拟器:
# flutter build ios --simulator

# 要签名才能装到真机或出 ipa:
# flutter build ipa
```

`flutter build ios` 默认只出真机 arm64. 模拟器架构由 Xcode 的 `ARCHS` 决定, 再由 `lipo` 合成 `libhikari_http.a`.

rust 桥接层引入了不少复杂度.

报错优先查本机环境和工具配置, 确保环境变量修改后重启终端或 `ide`

若是构建流程问题, 哪儿报错改哪儿, good luck :D
