//
//  CanopyContext.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum CanopyContext {
    nonisolated private static let threadKey: String = "CanopyContext.current"

    nonisolated static var current: String? {
        get {
            Thread.current.threadDictionary[threadKey] as? String
        }
        set {
            Thread.current.threadDictionary[threadKey] = newValue
        }
    }

    #if canImport(UIKit)
    static func push(viewController: UIViewController) {
        current = String(describing: type(of: viewController))
    }

    static func push(scrollView: UIScrollView) {
        current = "ScrollView.\(scrollView.hash)"
    }
    #endif
}
