//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import UserNotifications

protocol NotificationManager {
    typealias AuthorizationCompletion = (Bool, Error?) -> Void
    typealias AuthorizationStatusCompletion = (UNAuthorizationStatus) -> Void
    typealias SetNotificationCompletion = (Error?) -> Void
    
    func requestAuthorization(completion: AuthorizationCompletion)
    func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion)
    func setNotification(for fireDate: Date, title: String, body: String?, completion: SetNotificationCompletion)
    
    var forbiddenHours: [Int] { get }
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
        let error = NSError(domain: "error", code: -1)
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
        let forbiddenHour = sut.forbiddenHours.randomElement()!
        let fireDate = Date().set(hour: forbiddenHour)
        
        let exp = expectation(description: "waiting for completion...")
        sut.setNotification(for: fireDate, title: "", body: "") { error in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: SpyNM, notificationCeter: MockNotificationCenter) {
        let notificationCenter = MockNotificationCenter()
        let sut = SpyNM(notificationCenter: notificationCenter)
        
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
    
    private class SpyNM: NotificationManager {
        
        let notificationCenter: MockNotificationCenter
        
        init(notificationCenter: MockNotificationCenter) {
            self.notificationCenter = notificationCenter
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
        
        func setNotification(for fireDate: Date, title: String, body: String?, completion: SetNotificationCompletion) {
            completion(NSError(domain: "error", code: -1))
        }
        
        var forbiddenHours: [Int] { return [10, 11, 00, 01, 02, 03, 04, 05, 06] }
    }
    
    private class MockNotificationCenter: MockUserNotificationCenterProtocol {
        // to make other tester easier, so no need to authorize everytime at the begin of each tests
        var authorizationRequest: (Bool, Error?) = (true, nil)
        var authorizationStatus: UNAuthorizationStatus = .notDetermined
        
        func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void)) {
            completionHandler(authorizationRequest.0, authorizationRequest.1)
        }
        
        func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {
            UNNotificationSettings.fakeAuthorizationStatus = authorizationStatus
            let settingsCoder = MockNSCoder()
            let settings = UNNotificationSettings(coder: settingsCoder)!

            completionHandler(settings)
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
    }
}

private protocol MockUserNotificationCenterProtocol: AnyObject {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void))
    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void)
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
