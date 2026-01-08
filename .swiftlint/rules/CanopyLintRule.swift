import Foundation
import SourceKittenFramework
import SwiftLintFramework

public struct CanopyRule: ConfigurationProviderRule {
    public var configurationDescription = RuleConfigurationDescription(
        identifier: "canopy_custom_rules",
        name: "Canopy Custom Rules",
        description: "Custom rules specific to Canopy logging framework"
    )

    public init() {}
}

public struct NoExcessiveLoggingRule: OptInRule {
    public var configuration = SeverityConfiguration(warning: .warning)

    private let pattern = "(?i)\\.(v|d|i|w|e)(\\(|\\()"

    public init() {}

    public func validate(file: SwiftLintFile) -> [StyleViolation] {
        violations(in: file, pattern: pattern, configuration: configuration)
    }

    private func violations(in file: SwiftLintFile, pattern: NSRegularExpression, configuration: SeverityConfiguration) -> [StyleViolation] {
        guard let fileContent = file.contents else { return [] }

        let lines = fileContent.components(separatedBy: .newlines)
        var violations = [StyleViolation]()

        for (index, line) in lines.enumerated() {
            let range = NSRange(location: 0, length: line.utf16.count)
            if let match = pattern.firstMatch(in: line, options: [], range: range) {
                let violation = StyleViolation(
                    ruleDescription: type(of: self).description,
                    severity: configuration.severity(for: match),
                    location: Location(
                        file: file.path,
                        line: index + 1,
                        character: match.range.location
                    )
                )
                violations.append(violation)
            }
        }

        return violations
    }
}

extension NoExcessiveLoggingRule: RuleDescription {
    public var description: String {
        return "Warns when logging calls are used excessively in production code"
    }

    public var nonTriggeringExamples: [String] {
        return [
            """
            #if DEBUG
            Canopy.d("Detailed debug info")
            #endif
            """
        ]
    }

    public var triggeringExamples: [String] {
        return [
            """
            // Too many logging calls in a single function
            func processData() {
                Canopy.d("Step 1")
                Canopy.d("Step 2")
                Canopy.d("Step 3")
                Canopy.d("Step 4")
                Canopy.d("Step 5")
            }
            """
        ]
    }
}

public struct CanopyFormatStringRule: OptInRule {
    public var configuration = SeverityConfiguration(warning: .error)

    private let formatPattern = "(?i)canopy\\.\\.(v|d|i|w|e)(\\(|\\()"

    public init() {}

    public func validate(file: SwiftLintFile) -> [StyleViolation] {
        guard let fileContent = file.contents else { return [] }

        var violations = [StyleViolation]()
        let lines = fileContent.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            let nsRange = NSRange(location: 0, length: line.utf16.count)

            // Check for String.format() usage in Canopy calls
            if line.range(of: "String.format") != nil {
                let violation = StyleViolation(
                    ruleDescription: type(of: self).description,
                    severity: configuration.severity(for: nil),
                    location: Location(
                        file: file.path,
                        line: index + 1,
                        character: line.nsRange(of: "String.format")?.location ?? 0
                    )
                )
                violations.append(violation)
            }
        }

        return violations
    }
}

extension CanopyFormatStringRule: RuleDescription {
    public var description: String {
        return "Discourages String.format() in Canopy logging calls"
    }

    public var nonTriggeringExamples: [String] {
        return [
            """
            // GOOD: Use Canopy's format strings
            Canopy.d("User %s logged in", username)

            // GOOD: Use string interpolation
            Canopy.d("User \\(username) logged in")
            """
        ]
    }

    public var triggeringExamples: [String] {
        return [
            """
            // BAD: String.format is redundant
            Canopy.d(String.format("User %s logged in", username))

            // BAD: String.format can cause crashes with certain inputs
            Canopy.w(String.format("URL is %s", url))
            """
        ]
    }
}
