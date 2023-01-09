//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UserNotifications

extension XCTestCase {
    // XCTAssert like this becuase comparing two `Array`s may fail because of orders and keeping orders is also important so I couldn't use `Set`
    func assertThat(_ notificationCenter: MockNotificationCenter, deletedNotificationRequestsWithIds ids: [String], file: StaticString = #file, line: UInt = #line) {
        let actualRequests = notificationCenter.deletedNotificationRequests
        XCTAssertEqual(actualRequests.count, ids.count, "expected to get \(ids.count) deleted requests but got (\(actualRequests.count) deleted requests.", file: file, line: line)
        ids.forEach { id in
            XCTAssertTrue(actualRequests.contains(id), "expected to have deleted request with id \(id) but it isn't exist.", file: file, line: line)
        }
    }
    
    func assertThat(_ notificationCenter: MockNotificationCenter, addedNotificationRequestWithItems items: [NotificationRequestParamaters], file: StaticString = #file, line: UInt = #line) {
        guard notificationCenter.addedNotificationRequests.count == items.count else {
            return XCTFail("expected to get \(items.count) notification requests but got \(notificationCenter.addedNotificationRequests.count).", file: file, line: line)
        }
        for (index, item) in items.enumerated() {
            let notificationRequest = getNotificationRequest(notificationCenter, at: index)
            assertThat(notificationRequest, hasSameId: item.id, andCategoryId: item.categoryId, file: file, line: line)
            assertThat(notificationRequest, hasSameTitle: item.title, andBody: item.body, file: file, line: line)
            assertThat(notificationRequest, hasSameFireDate: item.fireDate, file: file, line: line)
        }
    }
    
    func assertThat(_ notificationRequest: UNNotificationRequest, hasSameId id: String, andCategoryId categoryId: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationRequest.identifier, id, "identifiers are not same.", file: file, line: line)
        XCTAssertEqual(notificationRequest.content.categoryIdentifier, categoryId, "category identifiers are not same.", file: file, line: line)
    }
    
    func assertThat(_ notificationRequest: UNNotificationRequest, hasSameTitle title: String, andBody body: String?, at index: Int = 0, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(notificationRequest.content.title, title, "titles are not same.", file: file, line: line)
        XCTAssertEqual(notificationRequest.content.body, body, "bodies are not same.", file: file, line: line)
    }
    
    func assertThat(_ notificationRequest: UNNotificationRequest, hasSameFireDate expectedFireDate: Date, file: StaticString = #file, line: UInt = #line) {
        let trigger = notificationRequest.trigger
        guard let calendarTrigger = trigger as? UNCalendarNotificationTrigger else {
            return XCTFail("expected to get \(UNCalendarNotificationTrigger.self).", file: file, line: line)
        }
        XCTAssertTrue(calendarTrigger.isEqual(toDate: expectedFireDate, calendar: self.calendar), "expected to have fire date at \(expectedFireDate) but got \(calendarTrigger.dateComponents)", file: file, line: line)
    }
    
    private func getNotificationRequest(_ notificationCenter: MockNotificationCenter, at index: Int = 0) -> UNNotificationRequest {
        return notificationCenter.addedNotificationRequests[index]
    }
}
