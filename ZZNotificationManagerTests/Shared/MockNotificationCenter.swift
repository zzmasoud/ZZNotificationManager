//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import UserNotifications
import ZZNotificationManager

class MockNotificationCenter: MockUserNotificationCenterProtocol {
    
    // to make other tester easier, so no need to authorize everytime at the begin of each tests
    var authorizationRequest: (Bool, Error?) = (true, nil)
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var addingNotificationError: Error? = nil
    var deletedNotificationRequests: [String] = []
    var addedNotificationRequests: [UNNotificationRequest] = []
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void)) {
        completionHandler(authorizationRequest.0, authorizationRequest.1)
    }
    
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
        UNNotificationSettings.fakeAuthorizationStatus = authorizationStatus
        let settingsCoder = MockNSCoder()
        let settings = UNNotificationSettings(coder: settingsCoder)!
        
        completionHandler(settings)
    }
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        addedNotificationRequests.append(request)
        completionHandler?(addingNotificationError)
    }
    
    func removePendingNotificationRequests(withIdentifiers ids: [String]) {
        deletedNotificationRequests.append(contentsOf: ids)
    }
    
    
    // MARK: - Async methods
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        if let error = authorizationRequest.1 {
            throw error
        } else {
            return authorizationRequest.0
        }
    }
    
    func notificationSettings() async -> UNNotificationSettings {
        let settingsCoder = MockNSCoder()
        let settings = UNNotificationSettings(coder: settingsCoder)!
        return settings
    }
    
    func add(_ request: UNNotificationRequest) async throws {
        if let error = addingNotificationError {
            throw error
        }
        addedNotificationRequests.append(request)
    }
    
    // MARK: - Simulate States
    
    func rejectAuthorization(with error: NSError? = nil) {
        authorizationRequest = (false, error)
    }
    
    func acceptAuthorization() {
        authorizationRequest = (true, nil)
    }
    
    func didNotAuthorized() {
        authorizationStatus = .notDetermined
    }
    
    func didDenyAuthorized() {
        authorizationStatus = .denied
    }
    
    func didAcceptAuthorized() {
        authorizationStatus = .authorized
    }
    
    func add(with error: Error?) {
        addingNotificationError = error
    }
    
    // MARK: - MockNSCoder
    
    class MockNSCoder: NSCoder {
        var authorizationStatus = UNNotificationSettings.fakeAuthorizationStatus.rawValue
        
        override func decodeInt64(forKey key: String) -> Int64 {
            return Int64(authorizationStatus)
        }
        
        override func decodeBool(forKey key: String) -> Bool {
            return true
        }
    }
}

// MARK: - UNNotificationSettings

fileprivate extension UNNotificationSettings {
    static var fakeAuthorizationStatus: UNAuthorizationStatus = .authorized
}
