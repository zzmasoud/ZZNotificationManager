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

import UserNotifications
extension ZZNotificationContent {
    static func map(key: CLOCNotificationSettingKey, settings: CLOCNotificationSetting) -> UNNotificationContent {
        Self.map(
            title: settings.title(forKey: key),
            categoryId: key.rawValue,
            body: settings.body(forKey: key)
        )
    }
}
