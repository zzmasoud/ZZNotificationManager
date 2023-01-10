//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import Foundation

extension CLOCNotificationManager {
    public func addProject(withId id: String, title: String, deadline: Date) async {
        guard let time = settings.time(forKey: .projectDeadlineReached) else { return }
        guard deadline > Date(timeIntervalSinceNow: time).addingTimeInterval(1.days) else { return }
        
        let specificDay = deadline.addingTimeInterval(-time)
        let fireDate = projectDeadlineTimeSetter.setTime(ofDate: specificDay)
        
        let key = CLOCNotificationSettingKey.projectDeadlineReached
        try? await notificationManager.setNotification(
            forDate: fireDate,
            andId: id,
            content: ZZNotificationContent.map(
                title: settings.title(forKey: key),
                categoryId: key.rawValue,
                body: settings.body(forKey: key)
            )
        )
    }
    
    public func deleteProjects(withIds ids: [String]) async {
        notificationManager.removePendingNotifications(withIds: ids)
    }
}
