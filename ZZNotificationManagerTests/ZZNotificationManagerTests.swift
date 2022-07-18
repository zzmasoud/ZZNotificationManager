//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import UserNotifications

protocol NotificationManager {
    typealias AuthorizationCompletion = (Bool, Error?) -> Void
    func requestAuthorization(completion: AuthorizationCompletion)
}

final class ZZNotificationManagerTests: XCTestCase {
    
    func test_init_doesNotAuthorize() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.authorizationCallCounts, 0)
    }
    
    func test_requestAuthorization_deliversFalseOnNotAuthorized() {
        let (sut, stub) = makeSUT()
        stub.rejectAuthorization()
        
        let exp = expectation(description: "waiting for completion...")
        sut.requestAuthorization { authorized, error in
            XCTAssertFalse(authorized)
            XCTAssertNil(error)
            XCTAssertEqual(sut.authorizationCallCounts, 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_requestAuthorization_deliversTrueOnAuthorized() {
        let (sut, stub) = makeSUT()
        stub.acceptAuthorization()
        
        let exp = expectation(description: "waiting for completion...")
        sut.requestAuthorization { authorized, error in
            XCTAssertTrue(authorized)
            XCTAssertNil(error)
            XCTAssertEqual(sut.authorizationCallCounts, 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_requestAuthorization_deliversFalseWithErrorOnNotAuthorizedAndFailedWithError() {
        let (sut, stub) = makeSUT()
        stub.rejectAuthorization(with: NSError(domain: "error", code: -1))
        
        let exp = expectation(description: "waiting for completion...")
        sut.requestAuthorization { authorized, error in
            XCTAssertFalse(authorized)
            XCTAssertNotNil(error)
            XCTAssertEqual(sut.authorizationCallCounts, 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: SpyNM, notificationCeter: MockNotificationCenter) {
        let notificationCenter = MockNotificationCenter()
        let sut = SpyNM(notificationCenter: notificationCenter)
        
        return (sut, notificationCenter)
    }
    
    private class SpyNM: NotificationManager {
        
        let notificationCenter: MockNotificationCenter
        private(set) var authorizationCallCounts = 0
        
        init(notificationCenter: MockNotificationCenter) {
            self.notificationCenter = notificationCenter
        }
        
        func requestAuthorization(completion: AuthorizationCompletion) {
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
                authorizationCallCounts += 1
                completion(authorized, error)
            }
        }
    }
    
    private class MockNotificationCenter: MockUserNotificationCenterProtocol {
        // to make other tester easier, so no need to authorize everytime at the begin of each tests
        var authorizationRequest: (Bool, Error?) = (true, nil)
        
        
        func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void)) {
            completionHandler(authorizationRequest.0, authorizationRequest.1)
        }
        
        func rejectAuthorization(with error: NSError? = nil) {
            authorizationRequest = (false, error)
        }
        
        func acceptAuthorization() {
            authorizationRequest = (true, nil)
        }
    }
}

private protocol MockUserNotificationCenterProtocol: AnyObject {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void))
    
}
