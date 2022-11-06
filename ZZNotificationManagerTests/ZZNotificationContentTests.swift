//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UserNotifications

public final class ZZNotificationContent {
    private init() { }
    
    public static func map(title: String, categoryId: String, body: String? = nil, subtitle: String? = nil, badge: Int? = nil, soundName: String? = nil) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.categoryIdentifier = categoryId

        return content
    }
}

class ZZNotificationContentTest: XCTestCase {
    
    func test_mapWithRequiredParameters_deliversSameValuesOnUNNotificationContent() {
        let title = "Title"
        let categoryId = UUID().uuidString
        
        let sut = ZZNotificationContent.map(title: title, categoryId: categoryId)
        
        XCTAssertEqual(sut.title, title)
        XCTAssertEqual(sut.categoryIdentifier, categoryId)
    }
}
