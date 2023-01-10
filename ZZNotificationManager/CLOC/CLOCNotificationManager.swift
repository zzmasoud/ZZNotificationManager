//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public class CLOCNotificationManager {
    public typealias NEED_RENAME = NotificationManager & AsyncNotificationManager
    
    static let instantTime: TimeInterval = 2
    
    let notificationManager: NEED_RENAME
    let settings: CLOCNotificationSetting
    let projectDeadlineTimeSetter: TimeSetter
    
    public init(notificationManager: NEED_RENAME, settings: CLOCNotificationSetting, projectDeadlineTimeSetter: TimeSetter) {
        self.notificationManager = notificationManager
        self.settings = settings
        self.projectDeadlineTimeSetter = projectDeadlineTimeSetter
    }
    
    open func calculateFutureDate(fromPassedTime passed: TimeInterval, andBorder border: TimeInterval?) -> Date? {
        guard let limit = border, passed < limit else { return nil }
        return Date(timeIntervalSinceNow: limit - passed)
    }
    
    public func instantNotification(key: CLOCNotificationSettingKey) async {
        await setNotification(forKey: key, withFireDate: Date().addingTimeInterval(Self.instantTime))
    }
    
    func setNotification(forKey key: CLOCNotificationSettingKey, withFireDate fireDate: Date) async {
        try? await notificationManager.setNotification(
            forDate: fireDate,
            andId: key.rawValue,
            content: ZZNotificationContent.map(key: key, settings: settings)
        )
    }
}
