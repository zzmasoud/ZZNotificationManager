//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

final class CLOCNotificationManagerTests: XCTestCase {

    func test_calculateFutureDate_returnsNilIfDateAlreadyPassed() {
        let passedTimeInterval = 40.minutes
        let limit = passedTimeInterval - 1.minutes
        let (sut, _, _) = makeSUT()
        
        let date = sut.calculateFutureDate(fromPassedTime: passedTimeInterval, andBorder: limit)
        
        XCTAssertNil(date)
    }
    
    func test_calculateFutureDate_returnsDateIfNotPassed() {
        let passedTimeInterval = 40.minutes
        let limit = passedTimeInterval + 15.minutes
        let (sut, _, _) = makeSUT()
        
        let date = sut.calculateFutureDate(fromPassedTime: passedTimeInterval, andBorder: limit)
        
        XCTAssertNotNil(date)
        XCTAssertTrue(date!.timeIntervalSinceNow > passedTimeInterval - limit)
        XCTAssertTrue(date!.timeIntervalSinceNow < limit)
    }
}
