//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import Foundation
import UserNotifications

public enum ZZNotificationAuthStatus {
    case authorized, notDetermined, denied
    
    public static func map(authorizationStatus auth: UNAuthorizationStatus) -> Self {
        switch auth {
        case .notDetermined:
            return Self.notDetermined
        case .denied:
            return Self.denied
        case .authorized:
            return Self.authorized
        case .provisional:
            return Self.authorized
        @unknown default:
            return Self.notDetermined
        }
    }
}
