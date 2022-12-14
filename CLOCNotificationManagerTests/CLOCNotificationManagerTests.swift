//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

enum CLOCNotificationSettingKey: String {
    case timerPassedTheDeadline, timerPassedTheDuration, noTasksHasBeenAddedSince
}

protocol CLOCNotificationSetting {
    func time(forKey: CLOCNotificationSettingKey) -> TimeInterval?
    func title(forKey: CLOCNotificationSettingKey) -> String
    func body(forKey: CLOCNotificationSettingKey) -> String?
}

class CLOCNotificationManager {
    typealias NEED_RENAME = NotificationManager & AsyncNotificationManager
    
    let notificationManager: NEED_RENAME
    let settings: CLOCNotificationSetting
    
    init(notificationManager: NEED_RENAME, settings: CLOCNotificationSetting) {
        self.notificationManager = notificationManager
        self.settings = settings
    }

    func calculateFutureDate(fromPassedTime passed: TimeInterval, andBorder border: TimeInterval?) -> Date? {
        guard let limit = border, passed < limit else { return nil }
        return Date(timeIntervalSinceNow: limit - passed)
    }
    
    func timerDidStop() async {
        removeTimerNotifications()
        guard let time = settings.time(forKey: .noTasksHasBeenAddedSince) else { return }
        let key = CLOCNotificationSettingKey.noTasksHasBeenAddedSince
        try? await notificationManager.setNotification(
            forDate: Date().addingTimeInterval(time),
            andId: key.rawValue,
            content: ZZNotificationContent.map(
                title: settings.title(forKey: key),
                categoryId: key.rawValue,
                body: settings.body(forKey: key)
            )
        )
    }
    
    private func removeTimerNotifications() {
        let keys = [CLOCNotificationSettingKey.timerPassedTheDuration, CLOCNotificationSettingKey.timerPassedTheDeadline].map { $0.rawValue }
        notificationManager.removePendingNotifications(withIds: keys)
    }
}

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
    
    func test_timerDidStop_removesTimerNotifications() async {
        let (sut, notificationCenter, _) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedTheDeadline]

        await sut.timerDidStop()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
    }
    
    func test_timerDidStop_DoesNotAddTaskReminderNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedTheDeadline]
        settings.noTasksHasBeenAddedSince = nil
        
        await sut.timerDidStop()

        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStop_addsTaskReminderNotificationIfValueExist() async {
        let (sut, notificationCenter, settings) = makeSUT()
        settings.noTasksHasBeenAddedSince = 20.minutes
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedTheDeadline]
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
    
    typealias NotificationRequestParamaters = (id: String, title: String, body: String?, fireDate: Date)
    
    var forbiddenHours: [Int] { [10, 11, 00, 1, 2, 3, 4, 5, 6] }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CLOCNotificationManager, notificationCenter: MockNotificationCenter, settings: MockNotificationSetting) {
        let calendar = Calendar.current
        let notificationCenter = MockNotificationCenter()
        let notificationManager = ZZNotificationManagerComposer.composedWith(notificationCenter: notificationCenter, calendar: calendar, forbiddenHours: forbiddenHours)
        let settings = MockNotificationSetting()
        
        let sut = CLOCNotificationManager(notificationManager: notificationManager, settings: settings)
        
        trackForMemoryLeaks(notificationCenter, file: file, line: line)
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, notificationCenter, settings)
    }
    
    // XCTAssert like this becuase comparing two `Array`s may fail because of orders and keeping orders is also important so I couldn't use `Set`
    private func assertThat(_ notificationCenter: MockNotificationCenter, deletedNotificationRequestsWithIds ids: [String]) {
        XCTAssertEqual(notificationCenter.deletedNotificationRequests.count, ids.count)
        ids.forEach { id in
            XCTAssertTrue(notificationCenter.deletedNotificationRequests.contains(id))
        }
    }
    
    private func assertThat(_ notificationCenter: MockNotificationCenter, addedNotificationRequestWithItems items: [NotificationRequestParamaters]) {
        guard notificationCenter.addedNotificationRequests.count == items.count else {
            return XCTFail("expected to get \(items.count) notification requests but got \(notificationCenter.addedNotificationRequests.count).")
        }
        for (index, item) in items.enumerated() {
            let notificationRequest = getNotificationRequest(notificationCenter, at: index)
            assertThat(notificationRequest, hasSameId: item.id)
            assertThat(notificationRequest, hasSameTitle: item.title, andBody: item.body)
            assertThat(notificationRequest, hasSameFireDate: item.fireDate)
        }
    }
    
    private func assertThat(_ notificationRequest: UNNotificationRequest, hasSameId id: String) {
        XCTAssertEqual(notificationRequest.identifier, id)
        XCTAssertEqual(notificationRequest.content.categoryIdentifier, id)
    }
    
    private func assertThat(_ notificationRequest: UNNotificationRequest, hasSameTitle title: String, andBody body: String?, at index: Int = 0) {
        XCTAssertEqual(notificationRequest.content.title, title)
        XCTAssertEqual(notificationRequest.content.body, body)
    }
    
    private func assertThat(_ notificationRequest: UNNotificationRequest, hasSameFireDate fireDate: Date) {
        let trigger = notificationRequest.trigger
        guard let calendarTrigger = trigger as? UNCalendarNotificationTrigger else {
            XCTFail("expected to get \(UNCalendarNotificationTrigger.self).")
            return
        }
        XCTAssertTrue(calendarTrigger.isEqual(toDate: fireDate, calendar: Calendar.current))
    }
    
    private func getNotificationRequest(_ notificationCenter: MockNotificationCenter, at index: Int = 0) -> UNNotificationRequest {
        return notificationCenter.addedNotificationRequests[index]
    }
    
    private class MockNotificationSetting: CLOCNotificationSetting {
        var noTasksHasBeenAddedSince: Double? = nil
        
        func time(forKey key: CLOCNotificationSettingKey) -> Double? {
            switch key {
            case .timerPassedTheDeadline:
                return nil
            case .timerPassedTheDuration:
                return nil
            case .noTasksHasBeenAddedSince:
                return noTasksHasBeenAddedSince
            }
        }
        
        func title(forKey key: CLOCNotificationSettingKey) -> String {
            switch key {
            case .timerPassedTheDeadline:
                return "-"
            case .timerPassedTheDuration:
                return "-"
            case .noTasksHasBeenAddedSince:
                return "noTasksHasBeenAddedSince-title"
            }
        }
        
        func body(forKey key: CLOCNotificationSettingKey) -> String? {
            switch key {
            case .timerPassedTheDeadline:
                return "-"
            case .timerPassedTheDuration:
                return "-"
            case .noTasksHasBeenAddedSince:
                return "noTasksHasBeenAddedSince-body"
            }
        }
    }
}

extension Int {
    var minutes: TimeInterval { Double(self) * 60 }
    var hours: TimeInterval { Double(self) * 60 * minutes }
    var days: TimeInterval { Double(self) * 24 * hours * minutes * 60 }
}

import UserNotifications

private extension UNCalendarNotificationTrigger {
    func isEqual(toDate date: Date, calendar: Calendar) -> Bool {
        guard let selfAsDate = calendar.date(from: self.dateComponents) else { return false }
        return calendar.compare(selfAsDate, to: date, toGranularity: .minute) == .orderedSame
    }
}
