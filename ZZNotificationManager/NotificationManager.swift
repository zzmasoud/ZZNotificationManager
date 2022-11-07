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

public final class ZZNotificationManager: NotificationManager {
    let notificationCenter: MockUserNotificationCenterProtocol
    let dontDisturbPolicy: DoNotDisturbPolicy
    
    public init(notificationCenter: MockUserNotificationCenterProtocol, dontDisturbPolicy: DoNotDisturbPolicy) {
        self.notificationCenter = notificationCenter
        self.dontDisturbPolicy = dontDisturbPolicy
    }
    
    public func requestAuthorization(completion: AuthorizationCompletion) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
            completion(authorized, error)
        }
    }
    
    public func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion) {
        notificationCenter.getNotificationSettings { settings in
            completion(ZZNotificationAuthStatus.map(authorizationStatus: settings.authorizationStatus))
        }
    }
    
    public func setNotification(forDate fireDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion) {
        guard dontDisturbPolicy.isSatisfied(fireDate) else {
            return completion(.forbiddenHour)
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let _ = error {
                completion(.system)
            } else {
                completion(nil)
            }
        }
    }
    
    public func removePendingNotifications(withIds ids: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
    }
}

extension ZZNotificationManager: AsyncNotificationManager {
    public func requestAuthorization() async throws -> Bool {
        return try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    public func checkAuthorizationStatus() async -> ZZNotificationAuthStatus {
        let settings = await notificationCenter.notificationSettings()
        return ZZNotificationAuthStatus.map(authorizationStatus: settings.authorizationStatus)
    }
    
    public func setNotification(forDate fireDate: Date, andId id: String, content: UNNotificationContent) async throws {
        guard dontDisturbPolicy.isSatisfied(fireDate) else {
            throw SetNotificationError.forbiddenHour
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        return try await notificationCenter.add(request)
    }
}
