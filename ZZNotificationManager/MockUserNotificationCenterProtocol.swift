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
