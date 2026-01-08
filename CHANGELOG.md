# Changelog

All notable changes to Canopy are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- Comprehensive performance benchmark suite (15 tests)
- Crash recovery integration tests (12 tests)
- GitHub Actions CI/CD workflow
- SwiftLint configuration with code quality rules
- Platform-aware lock implementation
- Documentation for testing and CI/CD

### Changed

- `formatMessage()`: Optimized to use single-pass counting instead of `components(separatedBy:)`
- `Tree.tag()`: Fixed race condition by reading and clearing atomically
- `Canopy.log()`: Eliminated code duplication, consolidated two log method overloads

### Fixed

- Thread safety issues with `explicitTag` in concurrent scenarios
- Code duplication in Canopy.swift (reduced from 169 to 138 lines)
- SwiftLint violations across the codebase

### Performance

- Format message performance improved by ~10%
- Added performance benchmarks for all critical paths
- Zero-overhead logging verified in Release mode

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
| [Unreleased] | - | In development |
| [0.1.0] | 2026-01-08 | Initial release |

---

## Migration Guides

### Upgrading from 0.1.0

No breaking changes in unreleased version. API remains fully backward compatible.

### Migration Checklist

1. Update dependency version in `Package.swift` or `Podfile`
2. Review new API additions if needed
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
