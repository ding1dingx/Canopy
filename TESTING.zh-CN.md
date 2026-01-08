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
|-------|-------|------|
| CanopyTests | 24 | 核心日志功能 |
| TreeTests | 12 | Tree 基类 |
| DebugTreeTests | 6 | DebugTree 功能 |
| AsyncTreeTests | 8 | AsyncTree 功能 |
| CrashBufferTreeTests | 6 | CrashBufferTree 功能 |

**总计：56 个测试**

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

---

## CI/CD

GitHub Actions 示例：

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Swift
        uses: swift-actions/setup-swift@v1
      - name: 运行测试
        run: swift test
      - name: 运行 SwiftLint
        run: brew install swiftlint && swiftlint
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
swift build clean
swift test
```

---

## 相关文档

- [贡献指南](CONTRIBUTING.zh-CN.md)
- [自述文件](README.zh-CN.md)
- [示例](Examples/README.zh-CN.md)
