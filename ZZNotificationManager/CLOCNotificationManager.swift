//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public enum CLOCNotificationSettingKey: String {
    case timerPassedItsDeadline, timerPassedTheDuration, noTasksHasBeenAddedSince
}

public protocol CLOCNotificationSetting {
    func time(forKey: CLOCNotificationSettingKey) -> TimeInterval?
    func title(forKey: CLOCNotificationSettingKey) -> String
    func body(forKey: CLOCNotificationSettingKey) -> String?
}

public class CLOCNotificationManager {
    public typealias NEED_RENAME = NotificationManager & AsyncNotificationManager
    
    let notificationManager: NEED_RENAME
    let settings: CLOCNotificationSetting
    
    public init(notificationManager: NEED_RENAME, settings: CLOCNotificationSetting) {
        self.notificationManager = notificationManager
        self.settings = settings
    }

    open func calculateFutureDate(fromPassedTime passed: TimeInterval, andBorder border: TimeInterval?) -> Date? {
        guard let limit = border, passed < limit else { return nil }
        return Date(timeIntervalSinceNow: limit - passed)
    }
    
    public func timerDidStop() async {
        removeTimerNotifications()
        guard let time = settings.time(forKey: .noTasksHasBeenAddedSince) else { return }
        
        let key = CLOCNotificationSettingKey.noTasksHasBeenAddedSince
        try? await notificationManager.setNotification(
            forDate: Date().addingTimeInterval(time),
            andId: key.rawValue,
            content: ZZNotificationContent.map(
                title: settings.title(forKey: key),
                categoryId: key.rawValue,
                body: settings.body(forKey: key)
            )
        )
    }
    
    private func removeTimerNotifications() {
        let keys = [CLOCNotificationSettingKey.timerPassedTheDuration, CLOCNotificationSettingKey.timerPassedItsDeadline].map { $0.rawValue }
        notificationManager.removePendingNotifications(withIds: keys)
    }
    
    public func timerDidStart(passed: TimeInterval = 0, deadline: TimeInterval = 0) async {
        removeTimerNotifications()
        await setTimerDeadlineNotificationIfPossible(passed: passed, deadline: deadline)
    }
    
    private func setTimerDeadlineNotificationIfPossible(passed: TimeInterval, deadline: TimeInterval) async {
        guard passed < deadline else { return }
        
        let remaining = deadline - passed
        let key = CLOCNotificationSettingKey.timerPassedItsDeadline
        try? await notificationManager.setNotification(
            forDate: Date().addingTimeInterval(remaining),
            andId: key.rawValue,
            content: ZZNotificationContent.map(
                title: settings.title(forKey: key),
                categoryId: key.rawValue,
                body: settings.body(forKey: key)
            )
        )
    }
}
