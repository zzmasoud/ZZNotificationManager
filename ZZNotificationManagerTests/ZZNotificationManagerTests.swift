//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import UserNotifications
import ZZNotificationManager

enum SetNotificationError: Error {
    case forbiddenHour
    case system
}

protocol NotificationManager {
    typealias AuthorizationCompletion = (Bool, Error?) -> Void
    typealias AuthorizationStatusCompletion = (UNAuthorizationStatus) -> Void
    typealias SetNotificationCompletion = (SetNotificationError?) -> Void
    
    func requestAuthorization(completion: AuthorizationCompletion)
    func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion)
    func setNotification(forDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion)
}

final class ZZNotificationManagerTests: XCTestCase {
    
    func test_requestAuthorization_deliversFalseOnNotAuthorized() {
        let (sut, notificationCenter) = makeSUT()
        
        notificationCenter.rejectAuthorization()
        
        assertThat(sut, deliversAuthorizationRequestWith: false)
    }
    
    func test_requestAuthorization_deliversTrueOnAuthorized() {
        let (sut, notificationCenter) = makeSUT()
        
        notificationCenter.acceptAuthorization()
        
        assertThat(sut, deliversAuthorizationRequestWith: true)
    }
    
    func test_requestAuthorization_deliversFalseWithErrorOnNotAuthorizedAndFailedWithError() {
        let error = anyNSError()
        let (sut, notificationCenter) = makeSUT()
        
        notificationCenter.rejectAuthorization(with: error)
        
        assertThat(sut, deliversAuthorizationRequestWith: false, andError: error)
    }
    
    func test_checkAuthorizationStatus_deliversNotDeterminedIfSettingsIsNotDetermined() {
        let (sut, notificationCenter) = makeSUT()
        
        notificationCenter.didNotAuthorized()
        
        assertThat(sut, deliversAuthorizationStatusWith: .notDetermined)
    }
    
    func test_checkAuthorizationStatus_deliversDeniedIfSettingsIsDenied() {
        let (sut, notificationCenter) = makeSUT()
        
        notificationCenter.didDenyAuthorized()
        
        assertThat(sut, deliversAuthorizationStatusWith: .denied)
    }
    
    func test_checkAuthorizationStatus_deliversAuthorizedIfSettingsIsAuhorized() {
        let (sut, notificationCenter) = makeSUT()
        
        notificationCenter.didAcceptAuthorized()
        
        assertThat(sut, deliversAuthorizationStatusWith: .authorized)
    }
    
    func test_setNotification_rejectIfDateIsInForbiddenHours() {
        let (sut, _) = makeSUT()
        let content = UNNotificationContent()
        let forbiddenHour = forbiddenHours.randomElement()!
        let fireDate = Date().set(hour: forbiddenHour)
        let id = UUID().uuidString
        let expectedError = SetNotificationError.forbiddenHour

        assertThat(sut, setsNotificationForDate: fireDate, withId: id, content: content, andCompletesWithError: expectedError)
    }
    
    func test_setNotification_passIfDateIsNotInForbiddenHours() {
        let (sut, _) = makeSUT()
        let content = UNNotificationContent()
        let notForbiddenHour = Set(Array(0...23)).subtracting(Set(forbiddenHours)).randomElement()!
        let fireDate = Date().set(hour: notForbiddenHour)
        let id = UUID().uuidString

        assertThat(sut, setsNotificationForDate: fireDate, withId: id, content: content, andCompletesWithError: nil)
    }
    
    func test_setNotification_deliversErrorOnSettingError() {
        let (sut, notificationCenter) = makeSUT()
        let content = UNNotificationContent()
        let notForbiddenHour = Set(Array(0...23)).subtracting(Set(forbiddenHours)).randomElement()!
        let fireDate = Date().set(hour: notForbiddenHour)
        let id = UUID().uuidString
        let expectedError = SetNotificationError.system

        notificationCenter.add(with: expectedError)
        
        assertThat(sut, setsNotificationForDate: fireDate, withId: id, content: content, andCompletesWithError: expectedError)
    }
    
    // MARK: - Helpers
    
    private var forbiddenHours: [Int] {
        [22,23,0,1,2,3,4,5]
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: SpyNM, notificationCeter: MockNotificationCenter) {
        let notificationCenter = MockNotificationCenter()
        let dontDisturbPolicy = ZZDoNotDisturbPolicy(forbiddenHours: forbiddenHours, calendar: Calendar.current)
        
        let sut = SpyNM(notificationCenter: notificationCenter, dontDisturbPolicy: dontDisturbPolicy)
        
        trackForMemoryLeaks(notificationCenter, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, notificationCenter)
    }
    
    private func assertThat(_ sut: NotificationManager, deliversAuthorizationRequestWith authorized: Bool, andError error: NSError? = nil, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion...")
        sut.requestAuthorization { gotAuthorized, gotError in
            XCTAssertEqual(authorized, gotAuthorized, file: file, line: line)
            XCTAssertEqual(error, gotError as? NSError, file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func assertThat(_ sut: NotificationManager, deliversAuthorizationStatusWith status: UNAuthorizationStatus, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion...")
        sut.checkAuthorizationStatus { gotStatus in
            XCTAssertEqual(status, gotStatus, file: file, line: line)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }
    
    private func assertThat(_ sut: NotificationManager, setsNotificationForDate fireDate: Date, withId id: String, content: UNNotificationContent, andCompletesWithError expectedError: SetNotificationError?) {
        let exp = expectation(description: "waiting for completion...")
        sut.setNotification(forDate: fireDate, andId: id, content: content) { error in
            XCTAssertEqual(expectedError, error)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: UUID().uuidString, code: [-10,0].randomElement()!)
    }
    
    private class SpyNM: NotificationManager {
        
        let notificationCenter: MockNotificationCenter
        let dontDisturbPolicy: DoNotDisturbPolicy
        
        init(notificationCenter: MockNotificationCenter, dontDisturbPolicy: DoNotDisturbPolicy) {
            self.notificationCenter = notificationCenter
            self.dontDisturbPolicy = dontDisturbPolicy
        }
        
        func requestAuthorization(completion: AuthorizationCompletion) {
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
                completion(authorized, error)
            }
        }
        
        func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion) {
            notificationCenter.getNotificationSettings { settings in
                completion(settings.authorizationStatus)
            }
        }
        
        func setNotification(forDate fireDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion) {
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
    }
    
    private class MockNotificationCenter: MockUserNotificationCenterProtocol {
        // to make other tester easier, so no need to authorize everytime at the begin of each tests
        var authorizationRequest: (Bool, Error?) = (true, nil)
        var authorizationStatus: UNAuthorizationStatus = .notDetermined
        var addingNotificationError: Error? = nil
        
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
            completionHandler?(addingNotificationError)
        }
        
        // --- Simulate States
        
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
    }
}

private protocol MockUserNotificationCenterProtocol: AnyObject {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void))
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)

}

extension UNNotificationSettings {
    static var fakeAuthorizationStatus: UNAuthorizationStatus = .authorized
}

class MockNSCoder: NSCoder {

    var authorizationStatus = UNNotificationSettings.fakeAuthorizationStatus.rawValue
    
    override func decodeInt64(forKey key: String) -> Int64 {
        return Int64(authorizationStatus)
    }
    
    override func decodeBool(forKey key: String) -> Bool {
        return true
    }
}

private extension Date {
    func set(hour: Int) -> Date {
        let calendar = Calendar.current
        
        return calendar.date(bySetting: .hour, value: hour, of: self)!
    }
}
