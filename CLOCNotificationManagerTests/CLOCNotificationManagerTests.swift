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
            forDate: Date(),
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

        await sut.timerDidStop()
        
        // XCTAssert like this becuase comparing two `Array`s may fail because of orders and keeping orders is also important so I couldn't use `Set`
        XCTAssertEqual(notificationCenter.deletedNotificationRequests.count, 2)
        XCTAssertTrue(notificationCenter.deletedNotificationRequests.contains(CLOCNotificationSettingKey.timerPassedTheDeadline.rawValue))
    }
    
    func test_timerDidStop_DoesNotAddTaskReminderNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        settings.noTasksHasBeenAddedSince = nil
        
        await sut.timerDidStop()

        XCTAssertEqual(notificationCenter.deletedNotificationRequests.count, 2)
        XCTAssertTrue(notificationCenter.deletedNotificationRequests.contains(CLOCNotificationSettingKey.timerPassedTheDeadline.rawValue))
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStop_addsTaskReminderNotificationIfValueExist() async {
        let (sut, notificationCenter, settings) = makeSUT()
        settings.noTasksHasBeenAddedSince = 20.minutes
        let key = CLOCNotificationSettingKey.noTasksHasBeenAddedSince
        
        await sut.timerDidStop()

        XCTAssertEqual(notificationCenter.deletedNotificationRequests.count, 2)
        XCTAssertTrue(notificationCenter.deletedNotificationRequests.contains(CLOCNotificationSettingKey.timerPassedTheDeadline.rawValue))
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 1)
        assertThat(notificationCenter, addedNotificationRequestWithId: key.rawValue)
        assertThat(notificationCenter, addedNotificationRequestWith: settings.title(forKey: key), body: settings.body(forKey: key))
    }
    
    // MARK: - Helpers
    
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
    
    private func assertThat(_ notificationCenter: MockNotificationCenter, addedNotificationRequestWithId id: String, at index: Int = 0) {
        XCTAssertEqual(notificationCenter.addedNotificationRequests[index].identifier, id)
        XCTAssertEqual(notificationCenter.addedNotificationRequests[0].identifier, id)
    }
    
    private func assertThat(_ notificationCenter: MockNotificationCenter, addedNotificationRequestWith title: String, body: String?, at index: Int = 0) {
        XCTAssertEqual(notificationCenter.addedNotificationRequests[index].content.title, title)
        XCTAssertEqual(notificationCenter.addedNotificationRequests[index].content.body, body)
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
