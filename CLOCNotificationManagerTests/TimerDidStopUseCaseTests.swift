//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UserNotifications
import ZZNotificationManager

final class TimerDidStopUseCaseTests: XCTestCase {
    func test_timerDidStop_removesTimerNotifications() async {
        let (sut, notificationCenter, _) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]

        await sut.timerDidStop()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
    }
    
    func test_timerDidStop_doesNotAddTaskReminderNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        settings.noTasksHasBeenAddedSince = nil
        
        await sut.timerDidStop()

        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStop_addsTaskReminderNotificationIfValueExist() async {
        let (sut, notificationCenter, settings) = makeSUT()
        settings.noTasksHasBeenAddedSince = 20.minutes
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        let expectedDate = Date().addingTimeInterval(settings.noTasksHasBeenAddedSince!)
        let expectedKey = CLOCNotificationSettingKey.noTasksHasBeenAddedSince
        let expectedRequests: [NotificationRequestParamaters] = [
            (
                id: expectedKey.rawValue,
                title: settings.title(forKey: expectedKey),
                body: settings.body(forKey: expectedKey),
                fireDate: expectedDate
            )
        ]
        
        await sut.timerDidStop()

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
}
