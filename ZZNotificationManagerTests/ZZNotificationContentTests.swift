//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UserNotifications

public final class ZZNotificationContent {
    private init() {}
    
    public static func map(title: String, categoryId: String, body: String? = nil, subtitle: String? = nil, badge: Int? = nil, soundName: String? = nil) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.categoryIdentifier = categoryId
        if let body = body {
            content.body = body
        }
        if let subtitle = subtitle {
            content.subtitle = subtitle
        }
        if let badge = badge {
            content.badge = badge as NSNumber
        }
        if let soundName = soundName {
            content.sound = UNNotificationSound(named: UNNotificationSoundName.init(soundName))
        }
        
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
    
    func test_mapWithOptionalParameters_deliversSameValuesOnUNNotificationContent() {
        let title = "Title"
        let categoryId = UUID().uuidString
        let body = "Body"
        let subtitle = "Subtitle"
        let badge = 22
        let soundName = "123.mp3"
        
        let sut = ZZNotificationContent.map(title: title, categoryId: categoryId, body: body, subtitle: subtitle, badge: 22, soundName: soundName)
        
        XCTAssertEqual(sut.title, title)
        XCTAssertEqual(sut.categoryIdentifier, categoryId)
        XCTAssertEqual(sut.body, body)
        XCTAssertEqual(sut.subtitle, subtitle)
        XCTAssertEqual(sut.badge?.intValue, badge)
        XCTAssertEqual(sut.sound, UNNotificationSound(named: .init(soundName)))
    }
}
