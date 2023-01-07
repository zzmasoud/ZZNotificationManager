//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UserNotifications

extension XCTestCase {
    // XCTAssert like this becuase comparing two `Array`s may fail because of orders and keeping orders is also important so I couldn't use `Set`
    func assertThat(_ notificationCenter: MockNotificationCenter, deletedNotificationRequestsWithIds ids: [String], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationCenter.deletedNotificationRequests.count, ids.count, file: file, line: line)
        ids.forEach { id in
            XCTAssertTrue(notificationCenter.deletedNotificationRequests.contains(id), file: file, line: line)
        }
    }
    
    func assertThat(_ notificationCenter: MockNotificationCenter, addedNotificationRequestWithItems items: [NotificationRequestParamaters], file: StaticString = #file, line: UInt = #line) {
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
    
    func assertThat(_ notificationRequest: UNNotificationRequest, hasSameId id: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationRequest.identifier, id, file: file, line: line)
        XCTAssertEqual(notificationRequest.content.categoryIdentifier, id, file: file, line: line)
    }
    
    func assertThat(_ notificationRequest: UNNotificationRequest, hasSameTitle title: String, andBody body: String?, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationRequest.content.title, title, file: file, line: line)
        XCTAssertEqual(notificationRequest.content.body, body, file: file, line: line)
    }
    
    func assertThat(_ notificationRequest: UNNotificationRequest, hasSameFireDate fireDate: Date, file: StaticString = #file, line: UInt = #line) {
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
