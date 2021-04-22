//
// Xcore
// Copyright © 2019 Xcore
// MIT license, see LICENSE file for details
//

import UIKit

// MARK: - Notification

extension UIApplication {
    /// Posted after the user interaction timeout.
    ///
    /// - See: `IdleTimer.setUserInteractionTimeout(duration:for:)`
    public static var didTimeOutUserInteractionNotification: Notification.Name {
        .init(#function)
    }

    /// - See: `IdleTimer.willTimeoutIdleTimer(duration:for:)`
    public static var willTimeOutIdleTimerNotification: Notification.Name {
        .init(#function)
    }
}

extension NotificationCenter.Event {
    /// Posted after the user interaction timeout.
    ///
    /// - See: `IdleTimer.setUserInteractionTimeout(duration:for:)`
    @discardableResult
    public func applicationDidTimeOutUserInteraction(_ callback: @escaping () -> Void) -> NSObjectProtocol {
        observe(UIApplication.didTimeOutUserInteractionNotification, callback)
    }
}

// MARK: - Gesture

extension IdleTimer {
    final private class Gesture: UIGestureRecognizer {
        private let onTouchesEnded: () -> Void

        init(onTouchesEnded: @escaping () -> Void) {
            self.onTouchesEnded = onTouchesEnded
            super.init(target: nil, action: nil)
            cancelsTouchesInView = false
        }

        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            onTouchesEnded()
            state = .failed
            super.touchesEnded(touches, with: event)
        }
    }
}

// MARK: - Windows

extension IdleTimer {
    final class WindowContainer {
        private let timer: InternalTimer
        private let warningTimer: InternalTimer
        var logoutWarning = ""
        private let warningTime: TimeInterval = 10 // seconds before voiceover announces the logout warning

        /// The timeout duration in seconds, after which idle timer notification is
        /// posted.
        var timeoutDuration: TimeInterval {
            get { timer.timeoutDuration }
            set {
                timer.timeoutDuration = newValue
                warningTimer.timeoutDuration = max(0, newValue - warningTime)
                warningTimer.logoutWarning = self.logoutWarning
            }
        }

        init() {
            timer = .init(timeoutAfter: 0) {
                NotificationCenter.default.post(name: UIApplication.didTimeOutUserInteractionNotification, object: nil)
            }

            warningTimer = .init(timeoutAfter: 0, logoutWarning: self.logoutWarning) {
                NotificationCenter.default.post(name: UIApplication.willTimeOutIdleTimerNotification, object: nil)
                UIAccessibility.post(notification: .announcement, argument: logoutWarning)
            }
        }

        func add(_ window: UIWindow) {
            if window.gestureRecognizers?.firstElement(type: IdleTimer.Gesture.self) != nil {
                // Return we already have the gesture added to the given window.
                return
            }

            let newGesture = Gesture { [weak self] in
                self?.timer.wake()
                self?.warningTimer.wake()
                self?.warningTimer.logoutWarning = self?.logoutWarning ?? ""
            }
            window.addGestureRecognizer(newGesture)
        }
    }
}
