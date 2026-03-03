//
//  LoggerBannerController.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 01/03/26.
//

#if DEBUG
import UIKit
import Combine
import NetScopeCore

public final class NetScopeController {

    public static let shared = NetScopeController()
    private init() {}

    private weak var keyWindow: UIWindow?
    private var bubbleView: NetScopeBubbleView?
    private var cancellables = Set<AnyCancellable>()
    private var entryCount = 0

    private var retryCount = 0
    private static let maxRetries = 10

    public func install() {
        DispatchQueue.main.async {
            guard self.bubbleView == nil else { return }

            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .foregroundActive })
                ?? UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first(where: { $0.activationState == .foregroundInactive })

            guard let windowScene = scene,
                  let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                    ?? windowScene.windows.first else {
                if self.retryCount < Self.maxRetries {
                    self.retryCount += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.install()
                    }
                } else {
                    print("⚠️ NetScope: no active window found after \(Self.maxRetries) retries.")
                }
                return
            }

            self.retryCount = 0
            self.keyWindow = keyWindow
            self.installBubble(in: keyWindow)
            self.subscribeToStore()
        }
    }

    public func uninstall() {
        DispatchQueue.main.async {
            self.bubbleView?.removeFromSuperview()
            self.bubbleView = nil
            self.cancellables.removeAll()
            self.entryCount = 0
        }
    }

    private func installBubble(in window: UIWindow) {
        let bubble = NetScopeBubbleView()
        bubble.onTap = { [weak self] in
            self?.openLogViewer()
        }
        bubble.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(bubble)

        NSLayoutConstraint.activate([
            bubble.widthAnchor.constraint(equalToConstant: 52),
            bubble.heightAnchor.constraint(equalToConstant: 52),
            bubble.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -12),
            bubble.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])

        bubbleView = bubble
    }

    private func subscribeToStore() {
        LogStore.shared.latestEntryPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entry in
                self?.onNewEntry(entry)
            }
            .store(in: &cancellables)
    }

    private func onNewEntry(_ entry: LogEntry) {
        entryCount += 1
        bubbleView?.update(count: entryCount, entry: entry)
    }

    private func openLogViewer() {
        entryCount = 0
        bubbleView?.resetCount()

        guard let presentingVC = topViewController() else {
            print("⚠️ NetScope: could not find top view controller to present log viewer")
            return
        }

        let viewer = NetScopeViewerHostingController()
        viewer.modalPresentationStyle = .fullScreen
        presentingVC.present(viewer, animated: true)
    }

    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }
        return findTopVC(from: rootVC)
    }

    private func findTopVC(from vc: UIViewController) -> UIViewController {
        if let presented = vc.presentedViewController { return findTopVC(from: presented) }
        if let nav = vc as? UINavigationController, let top = nav.topViewController { return findTopVC(from: top) }
        if let tab = vc as? UITabBarController, let selected = tab.selectedViewController { return findTopVC(from: selected) }
        return vc
    }
}
#endif
