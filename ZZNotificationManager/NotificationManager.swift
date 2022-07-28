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
}

public protocol NotificationManager {
    typealias AuthorizationCompletion = (Bool, Error?) -> Void
    typealias AuthorizationStatusCompletion = (UNAuthorizationStatus) -> Void
    typealias SetNotificationCompletion = (SetNotificationError?) -> Void
    
    func requestAuthorization(completion: AuthorizationCompletion)
    func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion)
    func setNotification(forDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion)
    func removePendingNotifications(withIds: [String])
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
            completion(settings.authorizationStatus)
        }
    }
    
    public func setNotification(forDate fireDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion) {
        guard dontDisturbPolicy.isSatisfied(fireDate) else {
            return completion(.forbiddenHour)
        }
        
        let components = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute, .second], from: fireDate)
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
