//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

class CLOCNotificationManager {
    let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
    
    func calculateEndDate(fromPassedTime passed: TimeInterval, andLimit limit: TimeInterval?) -> Date? {
        return nil
    }
}

final class CLOCNotificationManagerTests: XCTestCase {

    func test_calculateEndDate_returnsNilIfDateAlreadyPassed() {
        let passedTimeInterval = 40.minutes
        let limit = passedTimeInterval - 1.minutes
        let sut = makeSUT()
        
        let date = sut.calculateEndDate(fromPassedTime: passedTimeInterval, andLimit: limit)
        
        XCTAssertNil(date)
    }
    
    // MARK: - Helpers
    
    var forbiddenHours: [Int] { [10, 11, 00, 1, 2, 3, 4, 5, 6] }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CLOCNotificationManager {
        let calendar = Calendar.current
        let notificationCenter = MockNotificationCenter()
        let notificationManager = ZZNotificationManagerComposer.composedWith(notificationCenter: notificationCenter, calendar: calendar, forbiddenHours: forbiddenHours)
        
        let sut = CLOCNotificationManager(notificationManager: notificationManager)
        
        trackForMemoryLeaks(notificationCenter, file: file, line: line)
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }
}

extension Int {
    var minutes: TimeInterval { Double(self) * 60 }
    var hours: TimeInterval { Double(self) * 60 * minutes }
    var days: TimeInterval { Double(self) * 24 * hours * minutes * 60 }
}
