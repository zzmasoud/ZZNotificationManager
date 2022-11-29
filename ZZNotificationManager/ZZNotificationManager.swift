//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import UserNotifications

public final class ZZNotificationManager: NotificationManager {
    public typealias GetDateComponentsClosure = ((_ date: Date) -> DateComponents)

    let notificationCenter: MockUserNotificationCenterProtocol
    public var getDateComponentsFromDate: GetDateComponentsClosure
    public var dontDisturbPolicy: ((_ date: Date) -> Bool)?

    init(notificationCenter: MockUserNotificationCenterProtocol, getDateComponentsFromDate: @escaping GetDateComponentsClosure) {
        self.notificationCenter = notificationCenter
        self.getDateComponentsFromDate = getDateComponentsFromDate
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
        guard let policy = dontDisturbPolicy, policy(fireDate) else {
            return completion(.forbiddenHour)
        }
        
        let components = getDateComponentsFromDate(fireDate)
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
        guard let policy = dontDisturbPolicy, policy(fireDate) else {
            throw SetNotificationError.forbiddenHour
        }
        
        let components = getDateComponentsFromDate(fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        return try await notificationCenter.add(request)
    }
}
