//
//  File.swift
//  
//
//  Created by Manabu Nakazawa on 2/9/2022.
//

#if canImport(UIKit)

import UIKit

extension UIApplication {
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController?
        for scene in connectedScenes {
            guard let windowScene = scene as? UIWindowScene else {
                continue
            }
            for window in windowScene.windows {
                guard window.isKeyWindow else {
                    continue
                }
                topViewController = window.rootViewController
                if let presentedViewController = topViewController?.presentedViewController {
                    topViewController = presentedViewController
                }
            }
        }
        return topViewController
    }

    func visibleViewController() -> UIViewController? {
        return visibleViewControllers().first
    }

    func visibleViewControllers() -> [UIViewController] {
        guard let root = topViewController() else { return [] }
        let leaves = visibleLeaves(from: root, excluding: [UIAlertController.self])
        return leaves
    }

    private func visibleLeaves(from parent: UIViewController, excluding excludedTypes: [UIViewController.Type] = []) -> [UIViewController] {
        let isExcluded: (UIViewController) -> Bool = { vc in
            excludedTypes.contains(where: { vc.isKind(of: $0) }) || vc.modalPresentationStyle == .popover
        }

        if let presented = parent.presentedViewController, !isExcluded(presented) {
            return self.visibleLeaves(from: presented, excluding: excludedTypes)
        }

        let visibleChildren = parent.children.filter {
            $0.isViewLoaded && $0.view.window != nil
        }

        let visibleLeaves = visibleChildren.flatMap {
            return self.visibleLeaves(from: $0, excluding: excludedTypes)
        }

        if !visibleLeaves.isEmpty {
            return visibleLeaves
        } else if !isExcluded(parent) {
            return [parent]
        } else {
            return []
        }
    }

    var hasNotch: Bool {
        currentWindow?.safeAreaInsets
            .top ?? 0 > 30
    }

    var hasHomeIndicator: Bool {
        currentWindow?.safeAreaInsets
            .bottom ?? 0 > 0
    }

    private var currentWindow: UIWindow? {
        connectedScenes
            .compactMap {
                ($0 as? UIWindowScene)?.windows.first(where: {
                    $0.isKeyWindow
                })
            }
            .first
    }
}

#endif
