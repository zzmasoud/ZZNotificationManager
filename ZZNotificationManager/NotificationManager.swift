//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import UserNotifications

public protocol NotificationManager {
    typealias AuthorizationCompletion = (Bool, Error?) -> Void
    typealias AuthorizationStatusCompletion = (ZZNotificationAuthStatus) -> Void
    typealias SetNotificationCompletion = (SetNotificationError?) -> Void
    
    func requestAuthorization(completion: @escaping AuthorizationCompletion)
    func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion)
    func setNotification(forDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion)
    func removePendingNotifications(withIds: [String])
}

public protocol AsyncNotificationManager {
    func requestAuthorization() async throws -> Bool
    func checkAuthorizationStatus() async -> ZZNotificationAuthStatus
    func setNotification(forDate: Date, andId id: String, content: UNNotificationContent) async throws -> Void
}
