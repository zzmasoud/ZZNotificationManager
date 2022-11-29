//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation

public final class ZZNotificationManagerComposer {
    private init() {}
    
    public static func composedWith(notificationCenter: MockUserNotificationCenterProtocol, calendar: Calendar, forbiddenHours: [Int]? = nil) -> ZZNotificationManager {

        let notificationManager = ZZNotificationManager(notificationCenter: notificationCenter, getDateComponentsFromDate: { date in
            calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        })
        
        if let forbiddenHours = forbiddenHours {
            let dontDisturbPolicy: DoNotDisturbPolicy = ZZDoNotDisturbPolicy(forbiddenHours: forbiddenHours, calendar: { calendar } )
            notificationManager.dontDisturbPolicy = { date in
                dontDisturbPolicy.isSatisfied(date)
            }
        }
        return notificationManager
    }
}
