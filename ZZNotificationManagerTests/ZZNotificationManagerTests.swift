//
//  ZZNotificationManagerTests.swift
//  ZZNotificationManagerTests
//
//  Copyright © 2022 zzmasoud. All rights reserved.
//

import XCTest

protocol NotificationManager {
    
}

final class ZZNotificationManagerTests: XCTestCase {
    
    func test_init_doesNotAuthorize() {
        let sut = SpyNM()
        
        XCTAssertEqual(sut.authorizationCallCounts, 0)
    }
    
    private class SpyNM: NotificationManager {
        private(set) var authorizationCallCounts = 0
    }
}
