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
    
    func test_checkAuthorization_deliversTrueOnAuthorized() {
        let (sut, stub) = makeSUT()
        stub.acceptAuthorization()
        
        let exp = expectation(description: "waiting for completion...")
        sut.checkAuthorization { authorized in
            XCTAssertTrue(authorized)
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
        
        func checkAuthorization(completion: (Bool) -> Void) {
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { authorized, error in
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
        
        func acceptAuthorization() {
            didRequestAuthorization = true
        }
    }
}

private protocol MockUserNotificationCenterProtocol: AnyObject {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: ((Bool, Error?) -> Void))
    
}
