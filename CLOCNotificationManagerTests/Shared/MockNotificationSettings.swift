//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import ZZNotificationManager

class MockNotificationSetting: CLOCNotificationSetting {
    var noTasksHasBeenAddedSince: Double? = nil
    var timerPassedTheDeadline: Double? = nil
    var timerPassedTheDuration: Double? = nil
    
    func time(forKey key: CLOCNotificationSettingKey) -> Double? {
        switch key {
        case .timerPassedTheDeadline:
            return timerPassedTheDeadline
        case .timerPassedTheDuration:
            return timerPassedTheDuration
        case .noTasksHasBeenAddedSince:
            return noTasksHasBeenAddedSince
        }
    }
    
    func title(forKey key: CLOCNotificationSettingKey) -> String {
        switch key {
        case .timerPassedTheDeadline:
            return "-"
        case .timerPassedTheDuration:
            return "-"
        case .noTasksHasBeenAddedSince:
            return "noTasksHasBeenAddedSince-title"
        }
    }
    
    func body(forKey key: CLOCNotificationSettingKey) -> String? {
        switch key {
        case .timerPassedTheDeadline:
            return "-"
        case .timerPassedTheDuration:
            return "-"
        case .noTasksHasBeenAddedSince:
            return "noTasksHasBeenAddedSince-body"
        }
    }
}
