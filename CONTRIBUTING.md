# Contributing to Canopy

Thank you for your interest in contributing to Canopy!

---

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

When creating a bug report, please include:
- Your iOS version
- Canopy version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Sample code if applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Describe the use case
- Explain why it would be useful
- Provide examples if possible

### Pull Requests

1. Fork the repository
2. Create a branch for your feature (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`swift test`)
5. Run SwiftLint (`swiftlint`)
6. Commit your changes (`git commit -m 'Add some amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Create a Pull Request

---

## Code Review Guidelines

### Before Submitting

- [ ] All tests pass (`swift test`)
- [ ] SwiftLint passes (`swiftlint`)
- [ ] No new warnings introduced
- [ ] Benchmark tests pass (if applicable)
- [ ] Documentation updated
- [ ] CHANGELOG.md updated

### Pull Request Checklist

- [ ] Code follows project conventions
- [ ] Tests added/updated for new functionality
- [ ] Benchmarks added for performance changes
- [ ] Documentation updated
- [ ] CHANGELOG.md updated with changes
- [ ] CI passes

### Code Style

- Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain existing formatting
- Run SwiftLint before submitting

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `perf`: Performance improvement
- `docs`: Documentation only
- `test`: Adding or modifying tests
- `refactor`: Code restructuring
- `chore`: Maintenance tasks

**Example:**
```
feat(Tree): improve explicitTag thread safety

- Fix race condition by reading and clearing atomically
- Add benchmark tests for performance verification

Closes #123
```

---

## Development Setup

### Prerequisites

- macOS 14.0+ or iOS 14.0+ deployment target
- Swift 5.0+
- Xcode 15.0+

### Getting Started

```bash
# Clone the repository
git clone https://github.com/ding1dingx/Canopy.git
cd Canopy

# Open in Xcode
open Canopy.xcodeproj

# Or use Swift Package Manager
swift package generate-xcodeproj
open Canopy.xcodeproj
```

### Running Tests

```bash
# All tests
swift test

# Specific test suite
swift test --filter CanopyTests

# With code coverage
swift test --enable-code-coverage
```

### Running Benchmarks

```bash
# Performance benchmarks
swift test --filter CanopyBenchmarkTests

# Crash recovery tests
swift test --filter CanopyCrashRecoveryTests
```

### Code Quality

```bash
# Install SwiftLint
brew install swiftlint

# Run linting
swiftlint

# Auto-fix issues
swiftlint --autocorrect
```

---

## Testing

### Test Requirements

- Test on iOS 14.0+ simulators
- Test on physical devices if possible
- Test both Debug and Release configurations
- Run performance benchmarks for performance changes

### Test Coverage

Canopy maintains comprehensive test coverage:

- **87 unit and integration tests**
- **15 performance benchmarks**
- **12 crash recovery tests**

All tests must pass before merging.

---

## Release Process

### Version Bump

1. Update version in `Package.swift`
2. Update CHANGELOG.md with new version
3. Create git tag (`git tag v0.2.2`)
4. Push tag (`git push origin v0.2.2`)

### Release Checklist

- [ ] All tests pass
- [ ] Benchmark tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in Package.swift
- [ ] Git tag created
- [ ] Release notes prepared

### Release Notes Format

```markdown
## v0.2.2

### New Features
- Feature description

### Bug Fixes
- Fixed issue description

### Performance
- Performance improvement details

### Breaking Changes
- Migration guide if applicable
```

---

## Project Structure

```
Canopy/
├── Canopy/
│   ├── Sources/
│   │   ├── Tree.swift           # Base class
│   │   ├── Canopy.swift         # Main API
│   │   ├── LogLevel.swift       # Log levels
│   │   ├── AsyncTree.swift      # Async wrapper
│   │   ├── CrashBufferTree.swift # Crash recovery
│   │   ├── DebugTree.swift      # Console output
│   │   ├── CanopyContext.swift  # Context support
│   │   └── Lock.swift           # Lock utilities
│   └── Canopy/                  # App delegate, etc.
├── CanopyTests/                 # Test files
│   ├── CanopyTests.swift
│   ├── TreeTests.swift
│   ├── AsyncTreeTests.swift
│   ├── DebugTreeTests.swift
│   ├── CrashBufferTreeTests.swift
│   ├── CanopyBenchmarkTests.swift  # Performance benchmarks
│   └── CanopyCrashRecoveryTests.swift
├── Examples/                    # Example integrations
│   ├── XLogTree.swift
│   ├── SentryTree.swift
│   └── RemoteLogTree.swift
├── .github/workflows/           # CI/CD
├── TESTING.md                   # Testing guide
├── CONTRIBUTING.md              # This file
├── README.md                    # Main documentation
└── Package.swift                # SPM manifest
```

---

## Communication

- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Pull Requests**: For code contributions

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
