//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import UserNotifications

public final class ZZNotificationContent {
    private init() {}
    
    public static func map(title: String, categoryId: String, body: String? = nil, subtitle: String? = nil, badge: Int? = nil, soundName: String? = nil) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.categoryIdentifier = categoryId
        if let body = body {
            content.body = body
        }
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        if let badge = badge {
            content.badge = badge as NSNumber
        }
        if let soundName = soundName {
            content.sound = UNNotificationSound(named: UNNotificationSoundName.init(soundName))
        }
        
        return content
    }
}
