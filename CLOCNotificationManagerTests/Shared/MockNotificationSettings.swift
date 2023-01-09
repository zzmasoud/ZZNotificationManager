//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import ZZNotificationManager

class MockNotificationSetting: CLOCNotificationSetting {
    var noTasksHasBeenAddedSince: Double? = nil
    var timerPassedItsDeadline: Double? = nil
    var timerPassedTheDuration: Double? = nil
    var projectDeadlineReached: Double? = nil
    
    func time(forKey key: CLOCNotificationSettingKey) -> Double? {
        switch key {
        case .timerPassedItsDeadline:
            return timerPassedItsDeadline
        case .timerPassedTheDuration:
            return timerPassedTheDuration
        case .noTasksHasBeenAddedSince:
            return noTasksHasBeenAddedSince
        case .projectDeadlineReached:
            return projectDeadlineReached
        }
    }
    
    func title(forKey key: CLOCNotificationSettingKey) -> String {
        switch key {
        case .timerPassedItsDeadline:
            return "timerPassedItsDeadline-title"
        case .timerPassedTheDuration:
            return "timerPassedTheDuration-title"
        case .noTasksHasBeenAddedSince:
            return "noTasksHasBeenAddedSince-title"
        case .projectDeadlineReached:
            return "-"
        }
    }
    
    func body(forKey key: CLOCNotificationSettingKey) -> String? {
        switch key {
        case .timerPassedItsDeadline:
            return "timerPassedItsDeadline-body"
        case .timerPassedTheDuration:
            return "timerPassedTheDuration-body"
        case .noTasksHasBeenAddedSince:
            return "noTasksHasBeenAddedSince-body"
        case .projectDeadlineReached:
            return "-"
        }
    }
}
