//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public enum CLOCNotificationSettingKey: String {
    case timerPassedItsDeadline,
         timerPassedTheDuration,
         noTasksHasBeenAddedSince,
         projectDeadlineReached
}

public protocol CLOCNotificationSetting {
    func time(forKey: CLOCNotificationSettingKey) -> TimeInterval?
    func title(forKey: CLOCNotificationSettingKey) -> String
    func body(forKey: CLOCNotificationSettingKey) -> String?
}
