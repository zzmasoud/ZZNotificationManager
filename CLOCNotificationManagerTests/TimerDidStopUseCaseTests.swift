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
                categoryId: expectedKey.rawValue,
                title: settings.title(forKey: expectedKey),
                body: settings.body(forKey: expectedKey),
                fireDate: expectedDate
            )
        ]
        
        await sut.timerDidStop()

        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        assertThat(notificationCenter, addedNotificationRequestWithItems: expectedRequests)
    }
}
