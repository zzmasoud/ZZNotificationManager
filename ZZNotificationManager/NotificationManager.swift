//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import UserNotifications

public protocol MockUserNotificationCenterProtocol: AnyObject {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void))
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func removePendingNotificationRequests(withIdentifiers: [String])
    
    // MARK: - async methods
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func notificationSettings() async -> UNNotificationSettings
    func add(_ request: UNNotificationRequest) async throws
}

public protocol NotificationManager {
    typealias AuthorizationCompletion = (Bool, Error?) -> Void
    typealias AuthorizationStatusCompletion = (ZZNotificationAuthStatus) -> Void
    typealias SetNotificationCompletion = (SetNotificationError?) -> Void
    
    func requestAuthorization(completion: AuthorizationCompletion)
    func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion)
    func setNotification(forDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion)
    func removePendingNotifications(withIds: [String])
}

public protocol AsyncNotificationManager {
    func requestAuthorization() async throws -> Bool
    func checkAuthorizationStatus() async -> ZZNotificationAuthStatus
    func setNotification(forDate: Date, andId id: String, content: UNNotificationContent) async throws -> Void
}
