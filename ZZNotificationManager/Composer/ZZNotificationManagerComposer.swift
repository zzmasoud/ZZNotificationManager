//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class ZZNotificationManagerComposer {
    private init() {}
    
    public static func composedWith(notificationCenter: MockUserNotificationCenterProtocol, calendar: Calendar, dontDisturbPolicy: DoNotDisturbPolicy) -> ZZNotificationManager {
        let notificationManager = ZZNotificationManager(notificationCenter: notificationCenter)
        notificationManager.dontDisturbPolicy = { date in
            dontDisturbPolicy.isSatisfied(date)
        }
        return notificationManager
    }
}
