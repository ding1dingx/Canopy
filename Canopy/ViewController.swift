//
//  ViewController.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import UIKit

class ViewController: UIViewController {

    private var crashBufferTree: CrashBufferTree?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Canopy Demo"
        view.backgroundColor = .systemBackground

        setupUI()

        // Get crash buffer tree from AppDelegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            crashBufferTree = appDelegate.crashBufferTree
        }

        Canopy.v("ViewController loaded")
        Canopy.i("Setup completed successfully")
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Canopy Logging Framework"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)

        // Verbose Log Button
        let verboseButton = createButton(title: "Verbose Log", color: .systemBlue, action: #selector(testVerbose))
        stackView.addArrangedSubview(verboseButton)

        // Debug Log Button
        let debugButton = createButton(title: "Debug Log", color: .systemGreen, action: #selector(testDebug))
        stackView.addArrangedSubview(debugButton)

        // Info Log Button
        let infoButton = createButton(title: "Info Log", color: .systemOrange, action: #selector(testInfo))
        stackView.addArrangedSubview(infoButton)

        // Warning Log Button
        let warningButton = createButton(title: "Warning Log", color: .systemYellow, action: #selector(testWarning))
        stackView.addArrangedSubview(warningButton)

        // Error Log Button
        let errorButton = createButton(title: "Error Log", color: .systemRed, action: #selector(testError))
        stackView.addArrangedSubview(errorButton)

        // Format Log Button
        let formatButton = createButton(title: "Format Log", color: .systemPurple, action: #selector(testFormat))
        stackView.addArrangedSubview(formatButton)

        // Tagged Log Button
        let taggedButton = createButton(title: "Tagged Log", color: UIColor(red: 0.0, green: 0.75, blue: 0.75, alpha: 1.0), action: #selector(testTagged))
        stackView.addArrangedSubview(taggedButton)

        // Async Log Button
        let asyncButton = createButton(title: "Async Log", color: .systemIndigo, action: #selector(testAsync))
        stackView.addArrangedSubview(asyncButton)

        // View Crash Buffer Button
        let viewBufferButton = createButton(title: "View Crash Buffer", color: .systemGray, action: #selector(viewCrashBuffer))
        stackView.addArrangedSubview(viewBufferButton)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func createButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func testVerbose() {
        Canopy.v("This is a verbose message")
        Canopy.v("Verbose with parameters: 42, test")
    }

    @objc private func testDebug() {
        Canopy.d("This is a debug message")
        Canopy.d("Debug with object: key: value")
    }

    @objc private func testInfo() {
        Canopy.i("This is an info message")
        Canopy.i("Info with array: 1, 2, 3")
    }

    @objc private func testWarning() {
        Canopy.w("This is a warning message")
        Canopy.w("Warning with count: 100")
    }

    @objc private func testError() {
        let error = NSError(domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error message"])

        let errorMessage = "This is an error message: \(error.localizedDescription)"
        Canopy.e(errorMessage)

        Canopy.e("Error without error object")
    }

    @objc private func testFormat() {
        Canopy.i("User John logged in at 14:30")
        Canopy.d("Value: 3.14, Count: 42, Name: Test")
    }

    @objc private func testTagged() {
        Canopy.tag("UserAction").i("User tapped a button")
        Canopy.tag("Network").d("Making API request to /users")
        Canopy.tag("Database").w("Slow query detected: 250 ms")
        Canopy.tag("Analytics").v("Event tracked: page_view")
    }

    @objc private func testAsync() {
        Canopy.v("Starting async logging test")

        guard let crashTree = crashBufferTree else {
            Canopy.w("No CrashBufferTree available for async wrapping")
            return
        }

        let asyncTree = AsyncTree(wrapping: crashTree)
        Canopy.plant(asyncTree)

        DispatchQueue.global(qos: .userInitiated).async {
            Canopy.v("Background task started")

            for i in 1...5 {
                Thread.sleep(forTimeInterval: 0.1)
                Canopy.d("Processing item %d of 5", i)
            }

            Canopy.i("Background task completed")
        }

        Canopy.v("Async logging configured")
    }

    @objc private func viewCrashBuffer() {
        guard let crashTree = crashBufferTree else {
            Canopy.w("No CrashBufferTree initialized")
            return
        }

        let logs = crashTree.recentLogs()
        let message = logs.isEmpty
            ? "No logs in crash buffer yet"
            : "Crash Buffer contains \(logs.components(separatedBy: "\n").count) logs:\n\n\(logs)"

        let alert = UIAlertController(
            title: "Crash Buffer",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

}
