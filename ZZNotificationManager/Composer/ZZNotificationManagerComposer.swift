//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class ZZNotificationManagerComposer {
    private init() {}
    
    public static func composedWith(notificationCenter: MockUserNotificationCenterProtocol, calendar: Calendar, forbiddenHours: [Int]) -> ZZNotificationManager {
        let notificationManager = ZZNotificationManager(notificationCenter: notificationCenter)
        let dontDisturbPolicy: DoNotDisturbPolicy = ZZDoNotDisturbPolicy(forbiddenHours: forbiddenHours, calendar: { calendar } )
        notificationManager.dontDisturbPolicy = { date in
            dontDisturbPolicy.isSatisfied(date)
        }
        return notificationManager
    }
}
