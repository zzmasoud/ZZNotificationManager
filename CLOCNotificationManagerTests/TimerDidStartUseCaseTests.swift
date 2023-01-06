//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager
import UserNotifications

final class TimerDidStartUseCaseTests: XCTestCase {
    
    func test_timerDidStart_removesTimerNotifications() async {
        let (sut, notificationCenter, _) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]

        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
    }
    
    func test_timerDidStart_doesNotAddTimerPassedItsDeadlineNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        settings.timerPassedItsDeadline = nil
        
        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_doesNotAddTimerPassedTheDurationNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        settings.timerPassedTheDuration = nil
        
        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_doesNotAddTimerPassedItsDeadlineNotificationIfValueExistsAndPassedDeadline() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        turnOnTimerPassedItsDeadlineNotification(onSettings: settings)
        let timer = simulateTimerStartedAndPassedDeadline()
        
        await sut.timerDidStart(passed: timer.passed, deadline: timer.deadline)
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_addsTimerPassedItsDeadlineNotificationIfValueExistsAndNotPassedDeadline() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        turnOnTimerPassedItsDeadlineNotification(onSettings: settings)
        let timer = simulateTimerStartedButNotPassedDeadline()
        let expectedDate = Date().addingTimeInterval(timer.deadline - timer.passed)
        let expectedKey = CLOCNotificationSettingKey.timerPassedItsDeadline
        let expectedRequests: [NotificationRequestParamaters] = [
            (
                id: expectedKey.rawValue,
                title: settings.title(forKey: expectedKey),
                body: settings.body(forKey: expectedKey),
                fireDate: expectedDate
            )
        ]
        
        await sut.timerDidStart(passed: timer.passed, deadline: timer.deadline)
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        assertThat(notificationCenter, addedNotificationRequestWithItems: expectedRequests)
    }
    
    // MARK: - Helpers
    
    // XCTAssert like this becuase comparing two `Array`s may fail because of orders and keeping orders is also important so I couldn't use `Set`
    private func assertThat(_ notificationCenter: MockNotificationCenter, deletedNotificationRequestsWithIds ids: [String], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationCenter.deletedNotificationRequests.count, ids.count, file: file, line: line)
        ids.forEach { id in
            XCTAssertTrue(notificationCenter.deletedNotificationRequests.contains(id), file: file, line: line)
        }
    }
    
    private func assertThat(_ notificationCenter: MockNotificationCenter, addedNotificationRequestWithItems items: [NotificationRequestParamaters], file: StaticString = #file, line: UInt = #line) {
        guard notificationCenter.addedNotificationRequests.count == items.count else {
            return XCTFail("expected to get \(items.count) notification requests but got \(notificationCenter.addedNotificationRequests.count).", file: file, line: line)
        }
        for (index, item) in items.enumerated() {
            let notificationRequest = getNotificationRequest(notificationCenter, at: index)
            assertThat(notificationRequest, hasSameId: item.id, file: file, line: line)
            assertThat(notificationRequest, hasSameTitle: item.title, andBody: item.body, file: file, line: line)
            assertThat(notificationRequest, hasSameFireDate: item.fireDate, file: file, line: line)
        }
    }
    
    private func assertThat(_ notificationRequest: UNNotificationRequest, hasSameId id: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationRequest.identifier, id, file: file, line: line)
        XCTAssertEqual(notificationRequest.content.categoryIdentifier, id, file: file, line: line)
    }
    
    private func assertThat(_ notificationRequest: UNNotificationRequest, hasSameTitle title: String, andBody body: String?, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationRequest.content.title, title, file: file, line: line)
        XCTAssertEqual(notificationRequest.content.body, body, file: file, line: line)
    }
    
    private func assertThat(_ notificationRequest: UNNotificationRequest, hasSameFireDate fireDate: Date, file: StaticString = #file, line: UInt = #line) {
        let trigger = notificationRequest.trigger
        guard let calendarTrigger = trigger as? UNCalendarNotificationTrigger else {
            return XCTFail("expected to get \(UNCalendarNotificationTrigger.self).", file: file, line: line)
        }
        XCTAssertTrue(calendarTrigger.isEqual(toDate: fireDate, calendar: self.calendar), file: file, line: line)
    }
    
    private func getNotificationRequest(_ notificationCenter: MockNotificationCenter, at index: Int = 0) -> UNNotificationRequest {
        return notificationCenter.addedNotificationRequests[index]
    }
    
    // MARK: - Simulate settings changes
    
    private func turnOnTimerPassedItsDeadlineNotification(onSettings settings: MockNotificationSetting) {
        // any number makes this case valid (means turned on)
        settings.timerPassedItsDeadline = 1.minutes

    }
    
    // MARK: - Simulate timer states
    
    // this happens when a user start tracking time on a 'paused' timer
    private func simulateTimerStartedAndPassedDeadline() -> (passed: TimeInterval, deadline: TimeInterval) {
        let timerDeadline = 20.minutes
        let timerPassedTime = timerDeadline + 1
        return (timerPassedTime, timerDeadline)
    }
    
    private func simulateTimerStartedButNotPassedDeadline() -> (passed: TimeInterval, deadline: TimeInterval) {
        let timerDeadline = 20.minutes
        let timerPassedTime = timerDeadline - 2.minutes
        return (timerPassedTime, timerDeadline)
    }
}
