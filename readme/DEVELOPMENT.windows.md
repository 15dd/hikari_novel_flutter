## 开发环境

Android APK 构建工具及流程的简单说明

### 工具链 (scoop)

```powershell
scoop install cmake flutter rustup nasm llvm ninja
```

- `nasm`: CMake 编译 BoringSSL 汇编。缺少时会报 `No CMAKE_ASM_NASM_COMPILER could be found`
- `llvm`: `bindgen` 读取 BoringSSL 头文件时需要 `libclang.dll`。缺少时会报 `Unable to find libclang`
- `ninja`: Android 构建把 `CMAKE_GENERATOR` 设为 Ninja, 以避免 CMake 走 Visual Studio 并改用其中自带的旧 NDK

已经装过的跳过即可, 有些包不在默认 `main` bucket 里, 缺少时先自己补 Scoop 源。

备注:

- 打 Windows 桌面版需要 `Visual Studio 2022: 使用 C++ 的桌面开发`。桌面版尚未测试。

### 环境变量 (user)


| Key                        | Value                                       |
| -------------------------- | ------------------------------------------- |
| `LIBCLANG_PATH`            | `%USERPROFILE%\scoop\apps\llvm\current\bin` |
| `FLUTTER_STORAGE_BASE_URL` | `https://storage.flutter-io.cn`             |
| `PUB_HOSTED_URL`           | `https://pub.flutter-io.cn`                 |


或临时在终端设置:

```powershell
$env:LIBCLANG_PATH = "$env:USERPROFILE\scoop\apps\llvm\current\bin"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.flutter-io.cn"
$env:PUB_HOSTED_URL = "https://pub.flutter-io.cn"
```

- `LIBCLANG_PATH`：让 `bindgen` 找到 `libclang.dll`。

---



## 常用命令



### 检查 Rust 网络层

确保 `rust` 桥接模块 `hikari_http` 能编过

```powershell
cd hikari_novel_flutter/rust
cargo check
```



### 重新生成 Flutter 绑定

修改 `rust/src/api.rs` 对外接口后, 要重新生成胶水层

```powershell
cargo install flutter_rust_bridge_codegen --version 2.11.1
cd hikari_novel_flutter
flutter_rust_bridge_codegen generate
```

codegen 版本与 pubspec.yaml 里的 flutter_rust_bridge: 2.11.1 对齐。

generate 命令读取当前目录的 `flutter_rust_bridge.yaml` (rust_root: rust/，dart_output: lib/src/rust)

不要手改 `lib/src/rust/frb_generated.dart` 和 `rust/src/frb_generated.rs`

### 构建 APK

```powershell
flutter clean
flutter pub get
flutter build apk

# build apk 默认目标包括:
#   - arm64-v8a
#   - armeabi-v7a (旧手机)
#   - x86_64 (模拟器)
#
# 只出真机包可以简化为:
flutter build apk --target-platform android-arm64
```

rust 桥接层引入了不少复杂度.

报错优先查本机环境和工具配置, 确保环境变量修改后重启 `cmd` 或 `ide`

若是构建流程问题, 哪儿报错改哪儿, good luck :D
