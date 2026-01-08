# Testing Guide

A comprehensive guide for testing Canopy logging framework.

---

## Running Tests

### Swift Package Manager (Recommended)

```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter CanopyTests
swift test --filter TreeTests
swift test --filter DebugTreeTests
swift test --filter AsyncTreeTests
swift test --filter CrashBufferTreeTests

# Verbose output
swift test --verbose

# Generate code coverage
swift test --enable-code-coverage
```

### Xcode

1. Open `Package.swift` in Xcode
2. Product → Scheme → Edit Scheme...
3. Select **Canopy** scheme → **Test** action
4. Press `⌘U` to run tests

---

## Test Suites

| Suite | Tests | Description |
|-------|-------|-------------|
| CanopyTests | 24 | Core logging functionality |
| TreeTests | 12 | Tree base class |
| DebugTreeTests | 6 | DebugTree functionality |
| AsyncTreeTests | 8 | AsyncTree functionality |
| CrashBufferTreeTests | 6 | CrashBufferTree functionality |

**Total: 56 tests**

---

## Code Quality

### SwiftLint

```bash
# Install
brew install swiftlint

# Run lint
swiftlint

# Auto-fix issues
swiftlint --autocorrect
```

Configuration: [`.swiftlint.yml`](.swiftlint.yml)

---

## CI/CD

Example GitHub Actions workflow:

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
      - name: Run tests
        run: swift test
      - name: Run SwiftLint
        run: brew install swiftlint && swiftlint
```

---

## Troubleshooting

### "Unable to find module 'XCTest'"

```bash
# Regenerate Xcode project
rm -rf *.xcodeproj *.xcworkspace
open Package.swift
```

### Tests not running

```bash
# Clean build cache
swift build clean
swift test
```

---

## Related

- [Contributing Guide](CONTRIBUTING.md)
- [README](README.md)
- [Examples](Examples/README.md)
