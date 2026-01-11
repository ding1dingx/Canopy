# Changelog

All notable changes to Canopy are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

---

## [0.2.2] - 2026-01-12

### Fixed

- **DebugTree accessibility**: Added explicit `public init()` to DebugTree to resolve compilation error when using DebugTree in external modules ("DebugTree initializer is inaccessible due to 'internal' protection level")

### BREAKING CHANGES

- **None** - This release is fully backward compatible with 0.2.1

---

## [0.2.1] - 2026-01-12

### Changed

- **CocoaPods source URL**: Updated `s.source` from SSH git protocol to HTTPS for improved compatibility

### Fixed

- None

### BREAKING CHANGES

- **None** - This release is fully backward compatible with 0.2.0

---

## [0.2.0] - 2026-01-09

### Added

- Comprehensive performance benchmark suite (15 tests)
- Crash recovery integration tests (12 tests)
- GitHub Actions CI/CD workflow
- SwiftLint configuration with code quality rules
- Platform-aware lock implementation
- Documentation for testing and CI/CD
- **Parameter validation**: CrashBufferTree now validates `maxSize` (must be > 0 and <= 10000)
- **Tag length validation**: CanopyContext.with() now validates tag length (max 100 characters)
- **Flush failure logging**: CrashBufferTree now logs flush failures via NSLog
- **Comprehensive test coverage**: Increased from 87 to 91 tests

### Changed

- `formatMessage()`: Optimized to use single-pass counting instead of `components(separatedBy:)`
- `Tree.tag()`: Fixed race condition by reading and clearing atomically
- `Canopy.log()`: Eliminated code duplication, consolidated two log method overloads
- **Empty tag format**: Improved readability - empty tags now display as `[priority]: message` instead of `[] message`
- **DebugTree log level**: Fixed `warning` level mapping from `.error` to `.debug` for accurate OSLogType mapping

### Fixed

- **Signal handler safety**: Removed `flush()` from signal handlers to prevent deadlocks (NSLock is not async-signal-safe)
- **AsyncTree context recovery**: Added `defer` to ensure CanopyContext is restored even if log() throws
- **CanopyContext.with()`: Added whitespace trimming and empty string handling
- **Tree.tag()`: Fixed logic to correctly handle empty and whitespace-only strings
- Thread safety issues with `explicitTag` in concurrent scenarios
- Code duplication in Canopy.swift (reduced from 169 to 138 lines)

### Performance

- Format message performance improved by ~10%
- Added performance benchmarks for all critical paths
- Zero-overhead logging verified in Release mode

### Security

- **CrashBufferTree**: Fixed potential deadlock in signal handlers by moving flush to atexit() handler
- **Input validation**: Added parameter validation to prevent invalid input scenarios

### BREAKING CHANGES

- **None** - This release is fully backward compatible with 0.1.0

---

## [Unreleased]

### Added

- (Future development section)

---

## [0.1.0] - 2026-01-08

### Added

- Core logging framework with Tree-based architecture
- DebugTree for console logging
- CrashBufferTree for crash recovery
- AsyncTree for background logging
- Tagged logging support via `Canopy.tag()`
- Context support via `CanopyContext`
- Demo application with interactive examples
- Comprehensive test suite (60 tests)
- Multi-language documentation (English/Chinese)

### Features

- **Tree Architecture**: Flexible pluggable logging trees
- **Zero-overhead Release**: DebugTree optimized out in Release builds
- **String Formatting**: C-style format specifiers (`%@`, `%d`, etc.)
- **Thread Safety**: Lock-protected concurrent access
- **iOS 14+ Support**: Pure Swift standard library implementation

### Documentation

- README.md with quick start and best practices
- TESTING.md with test suite documentation
- CONTRIBUTING.md with contribution guidelines
- Examples/README.md with integration examples

---

## Version History

| Version | Date | Status |
|---------|------|--------|
| [0.2.2] | 2026-01-12 | **Current Release** - Fix DebugTree accessibility |
| [0.2.1] | 2026-01-12 | Update source URL to HTTPS |
| [0.2.0] | 2026-01-09 | Stability & Security Improvements |
| [0.1.0] | 2026-01-08 | Initial release |

---

## Migration Guides

### Migration Guides

### Upgrading from 0.1.0 to 0.2.0

No breaking changes. API remains fully backward compatible. Recommended changes:

1. **New validations**: CrashBufferTree now validates `maxSize` parameter. Ensure your code uses valid values (1-10000).
2. **Improved tag handling**: Empty tags now display more cleanly. No action needed.
3. **Security fix**: Signal handler safety improved. No action needed.

### Migration Checklist

1. Update dependency version in `Package.swift` or `Podfile`
2. Review new parameter validation if using CrashBufferTree with custom maxSize
3. Run test suite to verify compatibility

---

## Release Schedule

Canopy follows a flexible release schedule:

- **Patch releases**: As needed for bug fixes
- **Minor releases**: Monthly for new features and improvements
- **Major releases**: As needed for breaking changes

---

## Acknowledgments

- Inspired by [Timber](https://github.com/JakeWharton/Timber) (Android)
- Performance benchmarks based on industry best practices
- Swift community for language design and best practices
