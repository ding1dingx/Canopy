# 测试指南

Canopy 日志框架的测试指南。

---

## 运行测试

### Swift Package Manager（推荐）

```bash
# 运行所有测试
swift test

# 运行特定测试套件
swift test --filter CanopyTests
swift test --filter TreeTests
swift test --filter DebugTreeTests
swift test --filter AsyncTreeTests
swift test --filter CrashBufferTreeTests
swift test --filter CanopyBenchmarkTests
swift test --filter CanopyCrashRecoveryTests

# 详细输出
swift test --verbose

# 生成代码覆盖率
swift test --enable-code-coverage
```

### Xcode

1. 在 Xcode 中打开 `Package.swift`
2. Product → Scheme → Edit Scheme...
3. 选择 **Canopy** scheme → **Test** 操作
4. 按 `⌘U` 运行测试

---

## 测试套件

| 套件 | 测试数 | 描述 |
|------|--------|------|
| CanopyTests | 33 | 核心日志功能（包括 Error 参数支持） |
| TreeTests | 15 | Tree 基类 |
| DebugTreeTests | 5 | DebugTree 功能 |
| AsyncTreeTests | 8 | AsyncTree 功能 |
| CrashBufferTreeTests | 9 | CrashBufferTree 功能 |
| CanopyBenchmarkTests | 15 | 性能基准测试 |
| CanopyCrashRecoveryTests | 12 | 崩溃恢复集成测试 |

**总计：102 个测试**

---

## 性能基准测试

Canopy 包含全面的性能基准测试，确保在不同场景下的最佳性能。

### 运行基准测试

```bash
# 运行所有基准测试
swift test --filter CanopyBenchmarkTests

# 运行特定基准测试
swift test --filter CanopyBenchmarkTests/testLogPerformance_noArgs
```

### 基准测试类别

| 类别 | 测试数 | 目的 |
|------|--------|------|
| 日志方法 | 3 | 测量 log() 方法基础性能 |
| 格式化消息 | 3 | 测量 formatMessage() 开销 |
| Canopy API | 4 | 测量 API 调用开销 |
| AsyncTree | 1 | 测量异步日志性能 |
| Tree 操作 | 2 | 测量 tag() 和 isLoggable() |
| 并发 | 2 | 测量高并发场景性能 |

### 基准测试结果（macOS 14, Apple Silicon M3）

| 测试 | 操作数 | 平均时间 | 每次操作 |
|------|--------|----------|----------|
| testLogPerformance_noArgs | 10,000 | ~2ms | ~200ns |
| testLogPerformance_singleArg | 10,000 | ~20ms | ~2μs |
| testFormatMessagePerformance | 10,000 | ~1ms | ~100ns |
| testConcurrentLoggingPerformance | 10,000 | ~100ms | ~10μs |
| testCrashBufferTree_loggingPerformance | 1,000 | ~20ms | ~20ns |

> 注意：结果会因设备和 iOS 版本而异。运行基准测试以获取您环境的测量值。

---

## 代码质量

### SwiftLint

```bash
# 安装
brew install swiftlint

# 运行检查
swiftlint

# 自动修复
swiftlint --autocorrect
```

配置：[`.swiftlint.yml`](.swiftlint.yml)

### SwiftLint 规则

Canopy 使用以下 SwiftLint 配置：

- **禁用**：`trailing_whitespace`, `todo`, `multiple_closures_with_trailing_closure`, `optional_data_string_conversion`, `function_parameter_count`
- **启用**：`empty_count`, `empty_string`, `force_unwrapping`, `explicit_init`, `first_where`, `overridden_super_call`, `redundant_nil_coalescing`, `vertical_whitespace_closing_braces`, `weak_delegate`

---

## CI/CD

Canopy 包含用于持续集成的 GitHub Actions 工作流。

### 工作流特性

- **SwiftLint**：每次推送/PR 时进行代码质量检查
- **多版本测试**：iOS 15.0, 16.0, 17.0
- **SPM 测试**：原生 Swift Package Manager 测试
- **基于路径的过滤**：跳过仅文档更改的 CI

### 工作流配置

工作流定义在 [`.github/workflows/ci.yml`](.github/workflows/ci.yml)。

```yaml
name: Canopy CI

on:
  push:
    branches: [main, master]
    paths-ignore:
      - '**.md'
      - 'docs/**'
      - 'Examples/**'
  pull_request:
    branches: [main, master]

jobs:
  lint:
    name: SwiftLint
    runs-on: macos-15

  build-and-test:
    name: Build & Test
    runs-on: macos-15

  spm-test:
    name: SPM Test (macOS)
    runs-on: macos-15
```

### 本地运行 CI

```bash
# 代码检查
swiftlint

# 测试
swift test

# Xcode 构建
xcodebuild -project Canopy.xcodeproj \
  -scheme Canopy \
  -destination "generic/platform=iOS Simulator" \
  build
```

---

## 常见问题

### "Unable to find module 'XCTest'"

```bash
# 重新生成 Xcode 项目
rm -rf *.xcodeproj *.xcworkspace
open Package.swift
```

### 测试无法运行

```bash
# 清理构建缓存
swift package reset
swift test
```

### 性能基准测试失败

基准测试使用 `measure {}` 可能有方差，这是正常的。如果测试持续失败，请检查：
- 系统资源（CPU/内存）
- 后台进程
- 温控降频

---

## 相关文档

- [贡献指南](CONTRIBUTING.zh-CN.md)
- [自述文件](README.zh-CN.md)
- [示例](Examples/README.zh-CN.md)
- [GitHub Actions CI](.github/workflows/ci.yml)
