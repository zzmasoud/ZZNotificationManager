//
//  ZZNotificationManagerTests.swift
//  ZZNotificationManagerTests
//
//  Copyright © 2022 zzmasoud. All rights reserved.
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
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: SpyNM, notificationCeter: NotificationCenterStub) {
        let stub = NotificationCenterStub()
        let sut = SpyNM(notificationCenter: stub)
        
        return (sut, stub)
    }
    
    private class SpyNM: NotificationManager {
        
        let notificationCenter: NotificationCenterStub
        private(set) var authorizationCallCounts = 0
        
        init(notificationCenter: NotificationCenterStub) {
            self.notificationCenter = notificationCenter
        }
        
        func checkAuthorization(completion: (Bool) -> Void) {
            let authorized = notificationCenter.authorize()
            completion(authorized)
        }
    }
    
    private class NotificationCenterStub {
        private var authorizationResponse = false
        
        func rejectAuthorization() {
            authorizationResponse = false
        }
        
        func authorize() -> Bool {
            return authorizationResponse
        }
    }
}
