//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import UserNotifications
import ZZNotificationManager

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
        let (fireDate, id, content) = makeNotificationRequestRequirements(inForbiddenHours: true)
        let expectedError = SetNotificationError.forbiddenHour

        assertThat(sut, setsNotificationForDate: fireDate, withId: id, content: content, andCompletesWithError: expectedError)
    }
    
    func test_setNotification_passIfDateIsNotInForbiddenHours() {
        let (sut, _) = makeSUT()
        let (fireDate, id, content) = makeNotificationRequestRequirements()

        assertThat(sut, setsNotificationForDate: fireDate, withId: id, content: content, andCompletesWithError: nil)
    }
    
    func test_setNotification_deliversErrorOnSettingError() {
        let (sut, notificationCenter) = makeSUT()
        let (fireDate, id, content) = makeNotificationRequestRequirements()

        let expectedError = SetNotificationError.system
        notificationCenter.add(with: expectedError)
        
        assertThat(sut, setsNotificationForDate: fireDate, withId: id, content: content, andCompletesWithError: expectedError)
    }
    
    func test_removeNotifications_deletesPendingsWithRelatedIds() {
        let (sut, notificationCenter) = makeSUT()
        let (fireDate, id, content) = makeNotificationRequestRequirements()
        assertThat(sut, setsNotificationForDate: fireDate, withId: id, content: content, andCompletesWithError: nil)
        
        sut.removePendingNotifications(withIds: [id])
        
        XCTAssertEqual(notificationCenter.deletedNotificationRequests, [id])
    }
    
    // MARK: - Helpers
    
    private var forbiddenHours: [Int] {
        [22,23,0,1,2,3,4,5]
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NotificationManager, notificationCeter: MockNotificationCenter) {
        let notificationCenter = MockNotificationCenter()
        let dontDisturbPolicy = ZZDoNotDisturbPolicy(forbiddenHours: forbiddenHours, calendar: Calendar.current)
        
        let sut = ZZNotificationManager(notificationCenter: notificationCenter, dontDisturbPolicy: dontDisturbPolicy)
        
        trackForMemoryLeaks(dontDisturbPolicy, file: file, line: line)
        trackForMemoryLeaks(notificationCenter, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, notificationCenter)
    }
    
    private func makeNotificationRequestRequirements(inForbiddenHours: Bool = false) -> (fireDate: Date, id: String, content: UNNotificationContent) {
        let content = UNNotificationContent()
        let selectedHour =
        inForbiddenHours ? forbiddenHours.randomElement()! : Set(Array(0...23)).subtracting(Set(forbiddenHours)).randomElement()!
        let fireDate = Date().set(hour: selectedHour)
        let id = UUID().uuidString

        return (fireDate, id, content)
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
        
    private class MockNotificationCenter: MockUserNotificationCenterProtocol {
        // to make other tester easier, so no need to authorize everytime at the begin of each tests
        var authorizationRequest: (Bool, Error?) = (true, nil)
        var authorizationStatus: UNAuthorizationStatus = .notDetermined
        var addingNotificationError: Error? = nil
        var deletedNotificationRequests: [String] = []
        
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
        
        func removePendingNotificationRequests(withIdentifiers ids: [String]) {
            deletedNotificationRequests.append(contentsOf: ids)
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
