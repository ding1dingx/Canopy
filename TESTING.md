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
swift test --filter CanopyBenchmarkTests
swift test --filter CanopyCrashRecoveryTests

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
| TreeTests | 15 | Tree base class |
| DebugTreeTests | 5 | DebugTree functionality |
| AsyncTreeTests | 8 | AsyncTree functionality |
| CrashBufferTreeTests | 9 | CrashBufferTree functionality |
| CanopyBenchmarkTests | 15 | Performance benchmarks |
| CanopyCrashRecoveryTests | 12 | Crash recovery integration |

**Total: 87 tests**

---

## Performance Benchmarks

Canopy includes comprehensive performance benchmarks to ensure optimal performance across different scenarios.

### Running Benchmarks

```bash
# Run all benchmarks
swift test --filter CanopyBenchmarkTests

# Run specific benchmark
swift test --filter CanopyBenchmarkTests/testLogPerformance_noArgs
```

### Benchmark Categories

| Category | Tests | Purpose |
|----------|-------|---------|
| Log Method | 3 | Measure log() method base performance |
| Format Message | 3 | Measure formatMessage() overhead |
| Canopy API | 4 | Measure API call overhead |
| AsyncTree | 1 | Measure async logging performance |
| Tree Operations | 2 | Measure tag() and isLoggable() |
| Concurrency | 2 | Measure high-concurrency scenarios |

### Sample Results (macOS 14, Apple Silicon M3)

| Test | Operations | Time (avg) | Per-operation |
|------|------------|------------|---------------|
| testLogPerformance_noArgs | 10,000 | ~2ms | ~200ns |
| testLogPerformance_singleArg | 10,000 | ~20ms | ~2μs |
| testFormatMessagePerformance | 10,000 | ~1ms | ~100ns |
| testConcurrentLoggingPerformance | 10,000 | ~100ms | ~10μs |
| testCrashBufferTree_loggingPerformance | 1,000 | ~20ms | ~20ns |

> Note: Results vary based on device and iOS version. Run benchmarks to get measurements for your environment.

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

### SwiftLint Rules

Canopy uses the following SwiftLint configuration:

- **Disabled**: `trailing_whitespace`, `todo`, `multiple_closures_with_trailing_closure`, `optional_data_string_conversion`, `function_parameter_count`
- **Opt-in**: `empty_count`, `empty_string`, `force_unwrapping`, `explicit_init`, `first_where`, `overridden_super_call`, `redundant_nil_coalescing`, `vertical_whitespace_closing_braces`, `weak_delegate`

---

## CI/CD

Canopy includes a comprehensive GitHub Actions workflow for continuous integration.

### Workflow Features

- **SwiftLint**: Code quality checks on every push/PR
- **Multi-version testing**: iOS 15.0, 16.0, 17.0
- **SPM testing**: Native Swift Package Manager tests
- **Path-based filtering**: Skips CI for documentation-only changes

### Workflow Configuration

The workflow is defined in [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

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

### Running CI Locally

```bash
# Lint
swiftlint

# Test
swift test

# Xcode build
xcodebuild -project Canopy.xcodeproj \
  -scheme Canopy \
  -destination "generic/platform=iOS Simulator" \
  build
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
swift package reset
swift test
```

### Performance benchmark tests failing

Benchmarks use `measure {}` which may have variance. This is normal. If tests consistently fail, check:
- System resources (CPU/memory)
- Background processes
- Thermal throttling

---

## Related

- [Contributing Guide](CONTRIBUTING.md)
- [README](README.md)
- [Examples](Examples/README.md)
- [GitHub Actions CI](.github/workflows/ci.yml)
