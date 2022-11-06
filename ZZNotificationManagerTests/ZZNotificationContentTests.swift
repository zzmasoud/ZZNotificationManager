//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import UserNotifications
import ZZNotificationManager

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
