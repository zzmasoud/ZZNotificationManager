//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import ZZNotificationManager
import UserNotifications

class NotificationManagerSpy: NotificationManager {
    var authorizationStatus: [(Bool, Error?) -> Void] = []
    var authorizeCallCount: Int { authorizationStatus.count }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        authorizationStatus.append(completion)
    }
    
    func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion) {
        fatalError()
    }
    
    func setNotification(forDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion) {
        fatalError()
    }

    func removePendingNotifications(withIds: [String]) {
        fatalError()
    }
}
