//
//  Coordinator.swift
//  Created by Daniel Cardona Rojas on 17/10/19.
//  Copyright © 2019 Daniel Cardona Rojas. All rights reserved.
//

import UIKit
import Foundation

protocol CoordinatorDelegate: class {
    func childDidStart(_ coordinator: Coordinator)
    func childDidFinish(_ coordinator: Coordinator)
}

class Coordinator {
    // MARK: Tree structure
    weak var delegate: CoordinatorDelegate?
    var value: Configuration
    weak var parent: Coordinator?
    var children: [Coordinator] = []

    init(value: Configuration) {
        self.value = value
    }

    func add(child: Coordinator) {
        children.append(child)
        child.parent = self
    }

    func removeChild(_ coordinator: Coordinator) {
        if let match = children.firstIndex(where: { $0 === coordinator }) {
            children.remove(at: match)
        }
    }

    // MARK: Navigation related
    func start() {
        value.navigation?.pushViewController(value.initialView, animated: true)
    }

    func restart() {
        value.navigation?.popToViewController(value.initialView, animated: true)
    }

    final func end() {
        let initialVC = value.initialView

        if value.navigation?.presentingViewController != nil {
            dismiss(animated: true, completion: {
                self.parent?.delegate?.childDidFinish(self)
                self.parent?.removeChild(self)
            })
        } else {
            value.navigation?.popToViewControllerBefore(initialVC)
            self.parent?.delegate?.childDidFinish(self)
            self.parent?.removeChild(self)
        }

        print("\(Self.self) ended")
    }

    final func startChild(_ child: Coordinator, modal: Bool, animated: Bool) {
        child.value.navigation = modal ? UINavigationController.coordinated() : value.navigation
        add(child: child)
        child.start()
        delegate?.childDidStart(child)

        if let nav = child.value.navigation, modal {
            present(nav, animated: animated)
        }

        let msg = "\(Self.self) " + (modal ? "presenting" : "pushing") + " \(type(of: child.self))"
        print(msg)
    }

    // MARK: Helpers
    final func push(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        value.navigation?.pushViewController(viewController, animated: animated)
        print("\(Self.self) pushing: \(type(of: viewController))")
    }

    final func pop(animated: Bool, completion: (() -> Void)? = nil) {
        value.navigation?.popViewController(animated: animated, completion: completion)
    }

    final func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        value.navigation?.visibleViewController?.present(vc, animated: true, completion: completion)
    }

    final func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        value.navigation?.visibleViewController?.dismiss(animated: animated, completion: completion)
    }

    var currentCoordinator: Coordinator {
        return children.last?.currentCoordinator ?? children.last ?? self
    }

    deinit {
        print("\(Self.self) destroyed")
    }

}

class Configuration {
    var navigation: UINavigationController?
    var initialView: UIViewController

    init(initialView: UIViewController) {
        self.initialView = initialView
    }
}

extension UINavigationController {
    func popToViewControllerBefore(_ viewController: UIViewController) {
        guard let index = viewControllers.firstIndex(where: { $0 === viewController }) else {
            return
        }

        let beforeIndex = index - 1

        if 0..<viewControllers.count ~= beforeIndex {
            let targetVC = viewControllers[beforeIndex]
            popToViewController(targetVC, animated: true)
        }
    }
}

extension UINavigationController {
    static func coordinated() -> UINavigationController {
        let nav = UINavigationController()
        nav.navigationBar.isHidden = true
        nav.interactivePopGestureRecognizer?.isEnabled = false
        return nav
    }
}

extension UINavigationController {

    func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    func popViewController(animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }

    func popToRootViewController(animated: Bool, completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}
