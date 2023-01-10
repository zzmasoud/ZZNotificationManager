//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

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
