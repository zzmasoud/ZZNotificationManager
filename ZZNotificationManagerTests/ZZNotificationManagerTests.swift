//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import UserNotifications

protocol NotificationManager {
    
}

final class ZZNotificationManagerTests: XCTestCase {
    
    func test_init_doesNotAuthorize() {
        let (sut, _) = makeSUT()
        
        XCTAssertEqual(sut.authorizationCallCounts, 0)
    }
    
    func test_checkAuthorization_deliversFalseOnNotAuthorized() {
        let (sut, stub) = makeSUT()
        stub.rejectAuthorization()
        
        let exp = expectation(description: "waiting for completion...")
        sut.checkAuthorization { authorized in
            XCTAssertFalse(authorized)
            XCTAssertEqual(sut.authorizationCallCounts, 1)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: SpyNM, notificationCeter: MockNotificationCenter) {
        let stub = MockNotificationCenter()
        let sut = SpyNM(notificationCenter: stub)
        
        return (sut, stub)
    }
    
    private class SpyNM: NotificationManager {
        
        let notificationCenter: MockNotificationCenter
        private(set) var authorizationCallCounts = 0
        
        init(notificationCenter: MockNotificationCenter) {
            self.notificationCenter = notificationCenter
        }
        
        func checkAuthorization(completion: (Bool) -> Void) {
            notificationCenter.requestAuthorization(options: [.sound]) { authorized, error in
                authorizationCallCounts += 1
                completion(authorized)
            }
        }
    }
    
    private class MockNotificationCenter: MockUserNotificationCenterProtocol {
        // to make other tester easier, so no need to authorize everytime at the begin of each tests
        var didRequestAuthorization = true
        
        func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void)) {
            completionHandler(didRequestAuthorization, nil)
        }
        
        func rejectAuthorization() {
            didRequestAuthorization = false
        }
    }
}

private protocol MockUserNotificationCenterProtocol: AnyObject {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void))
    
}

extension UNUserNotificationCenter: MockUserNotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void)) {
        print("Requested Authorization")
    }
}

