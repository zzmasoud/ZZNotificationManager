//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

extension XCTestCase {
    typealias NotificationRequestParamaters = (id: String, categoryId: String, title: String, body: String?, fireDate: Date)
    
    var forbiddenHours: [Int] { [22, 23, 00, 1, 2, 3, 4, 5, 6] }
    var calendar: Calendar { Calendar.current }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CLOCNotificationManager, notificationCenter: MockNotificationCenter, settings: MockNotificationSetting) {
        let calendar = self.calendar
        let notificationCenter = MockNotificationCenter()
        let notificationManager = ZZNotificationManagerComposer.composedWith(notificationCenter: notificationCenter, calendar: calendar, forbiddenHours: forbiddenHours)
        let settings = MockNotificationSetting()
        
        let sut = CLOCNotificationManager(notificationManager: notificationManager, settings: settings)
        
        trackForMemoryLeaks(notificationCenter, file: file, line: line)
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, notificationCenter, settings)
    }
}
