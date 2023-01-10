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
    
    func test_instantNotification_addsNotificationWithInstantFireDate() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let expectedKey: CLOCNotificationSettingKey = .projectDeadlineReached
        let expectedDate = Date().addingTimeInterval(2)
        
        await sut.instantNotification(key: expectedKey)
        
        assertThat(notificationCenter, addedNotificationRequestWithItems: [
            (
                id: expectedKey.rawValue,
                categoryId: expectedKey.rawValue,
                title: settings.title(forKey: expectedKey),
                body: settings.body(forKey: expectedKey),
                fireDate: expectedDate
            ),
        ])
    }
}
