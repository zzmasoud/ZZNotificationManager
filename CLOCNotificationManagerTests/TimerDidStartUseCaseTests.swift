//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

final class TimerDidStartUseCaseTests: XCTestCase {
    
    func test_timerDidStart_removesTimerNotifications() async {
        let (sut, notificationCenter, _) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedTheDeadline]

        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
    }
    
    func test_timerDidStart_DoesNotAddTimerPassedTheDeadlineNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedTheDeadline]
        settings.timerPassedTheDeadline = nil
        
        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_DoesNotAddTimerPassedTheDurationNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedTheDeadline]
        settings.timerPassedTheDuration = nil
        
        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    // MARK: - Helpers
    
    // XCTAssert like this becuase comparing two `Array`s may fail because of orders and keeping orders is also important so I couldn't use `Set`
    private func assertThat(_ notificationCenter: MockNotificationCenter, deletedNotificationRequestsWithIds ids: [String], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationCenter.deletedNotificationRequests.count, ids.count, file: file, line: line)
        ids.forEach { id in
            XCTAssertTrue(notificationCenter.deletedNotificationRequests.contains(id), file: file, line: line)
        }
    }
}
