import Flutter
import UIKit
import UserNotifications

class WhoopServiceBridge: NSObject {
    private static let channelName = "com.whoopconnect.whoop_connect/service"
    private static let notifId = "whoop_hr_live"

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "startForegroundService":
                requestNotificationPermission()
                postHRNotification(hr: 0)
                result(nil)
            case "stopForegroundService":
                removeNotification()
                result(nil)
            case "updateNotification":
                let hr = (call.arguments as? [String: Any])?["heartRate"] as? Int ?? 0
                postHRNotification(hr: hr)
                result(nil)
            case "onDoubleTap":
                // No persistent notification action needed on iOS; BLE haptic is
                // handled by flutter_blue_plus writing to the characteristic directly.
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private static func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _, _ in }
    }

    private static func postHRNotification(hr: Int) {
        let content = UNMutableNotificationContent()
        content.title = "WHOOP Connect"
        content.body = hr > 0 ? "Heart rate: \(hr) bpm" : "Connecting..."
        content.sound = nil

        // Same identifier replaces any existing notification with this ID.
        let request = UNNotificationRequest(identifier: notifId, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { _ in }
    }

    private static func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notifId])
        center.removeDeliveredNotifications(withIdentifiers: [notifId])
    }
}
