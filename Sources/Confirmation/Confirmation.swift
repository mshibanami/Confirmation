//
//  Confirmation.swift
//  RedirectWebForSafari iOS
//
//  Created by Manabu Nakazawa on 19/3/22.
//  Copyright © 2022 Manabu Nakazawa. All rights reserved.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

public enum Confirmation {
    public enum Action: Equatable {
        case `default`(title: String, isPreferred: Bool = false)
        case destructive(title: String, isPreferred: Bool = false)
        case cancel(title: String? = nil)

        var title: String? {
            switch self {
            case .default(title: let title, _):
                return title
            case .destructive(title: let title, _):
                return title
            case .cancel(title: let title):
                return title
            }
        }
#if os(iOS)
        var uiAlertActionStyle: UIAlertAction.Style {
            switch self {
            case .default:
                return .default
            case .destructive:
                return .destructive
            case .cancel:
                return .cancel
            }
        }
#endif

        var isPreferred: Bool {
            switch self {
            case .default(_, isPreferred: let isPreferred):
                return isPreferred
            case .destructive(_, isPreferred: let isPreferred):
                return isPreferred
            case .cancel:
                return false
            }
        }
    }

    public enum ConfirmationError: Error {
        case cancelled
    }

    public enum Style {
#if os(macOS)
        case alert(NSWindow? = nil, style: NSAlert.Style = .warning)
        case sheet(NSWindow? = nil)

        var window: NSWindow? {
            switch self {
            case .alert(let window, _):
                return window
            case .sheet(let window):
                return window
            }
        }
#elseif os(iOS)
        case alert(UIViewController? = nil)
        case sheet(sourceView: UIView, viewController: UIViewController? = nil)

        var sourceView: UIView? {
            switch self {
            case .alert:
                return nil
            case .sheet(sourceView: let sourceView, _):
                return sourceView
            }
        }

        var viewController: UIViewController? {
            switch self {
            case .alert(viewController: let viewController):
                return viewController
            case .sheet(_, viewController: let viewController):
                return viewController
            }
        }
#endif
    }

    @MainActor public static func show(title: String?, description: String?, actions: [Action], style: Style) async -> Action? {
        assert(!actions.isEmpty)
#if os(macOS)
        let alert = NSAlert()
        alert.messageText = title ?? ""
        alert.informativeText = description ?? ""
        var selectedAction: Action?
        for action in actions {
            let button: NSButton
            switch action {
            case let .default(title: title, isPreferred: isPreferred):
                button = alert.addButton(withTitle: title)
                button.keyEquivalent = isPreferred ? "\r" : ""
            case let .destructive(title: title, isPreferred: isPreferred):
                button = alert.addButton(withTitle: title)
                button.hasDestructiveAction = true
                button.keyEquivalent = isPreferred ? "\r" : ""
            case .cancel:
                button = alert.addButton(withTitle: action.title ?? cancelText)
                button.keyEquivalent = "\u{1b}"
            }
            button.addAction {
                selectedAction = action
                switch style {
                case .alert:
                    (NSApp as EndSheetExecutable).endSheet(alert.window)
                case .sheet:
                    alert.window.endBeingSheeted()
                }
            }
        }
        switch style {
        case .alert(_, let style):
            alert.alertStyle = style
            alert.runModal()
        case .sheet(window: let window):
            guard let window = window ?? NSApp.keyWindow else {
                return nil
            }
            await alert.beginSheetModal(for: window)
        }

        if let selectedAction = selectedAction {
            return selectedAction
        } else {
            return actions.first(where: {
                if case .cancel = $0 {
                    return true
                }
                return false
            }) ?? actions.first ?? .cancel()
        }
#elseif os(iOS)
        guard let viewController = style.viewController ?? UIApplication.shared.visibleViewController() else {
            return nil
        }
        return await withUnsafeContinuation { (continuation: UnsafeContinuation<Action, Never>) in
            let sourceView = style.sourceView
            let alert = UIAlertController(
                title: title,
                message: description,
                preferredStyle: sourceView != nil ? .actionSheet : .alert)
            if let sourceView = sourceView {
                alert.popoverPresentationController?.sourceView = sourceView
                alert.popoverPresentationController?.sourceRect = sourceView.bounds
            }
            for action in actions {
                switch action {
                case .default, .destructive:
                    let alertAction = UIAlertAction(
                        title: action.title,
                        style: action.uiAlertActionStyle,
                        handler: { _ in
                            alert.dismiss(animated: true, completion: {
                                continuation.resume(with: .success(action))
                            })
                        })
                    alert.addAction(alertAction)
                    if action.isPreferred {
                        alert.preferredAction = alertAction
                    }
                case .cancel:
                    alert.addAction(UIAlertAction(
                        title: action.title ?? cancelText,
                        style: action.uiAlertActionStyle,
                        handler: { _ in
                            continuation.resume(with: .success(action))
                        }))
                }
            }
            viewController.present(alert, animated: true)
        }
#endif
    }

    static var cancelText: String {
        NSLocalizedString("cancelAction", tableName: "Localizable", bundle: .module, comment: "")
    }
}

#if os(macOS)
// HACK: To suppress deprecation warning.
protocol EndSheetExecutable {
    func endSheet(_ sheet: NSWindow)
    func endSheet(_ sheet: NSWindow) async
}

extension NSApplication: EndSheetExecutable {}
#endif
