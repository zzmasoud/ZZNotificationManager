//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager
import UserNotifications

final class TimerDidStartUseCaseTests: XCTestCase {
    
    func test_timerDidStart_removesTimerNotifications() async {
        let (sut, notificationCenter, _) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]

        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
    }
    
    func test_timerDidStart_doesNotAddTimerPassedItsDeadlineNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        settings.timerPassedItsDeadline = nil
        
        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_doesNotAddTimerPassedTheDurationNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        settings.timerPassedTheDuration = nil
        
        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_doesNotAddTimerPassedItsDeadlineNotificationIfValueExistsAndPassedDeadline() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        turnOnTimerPassedItsDeadlineNotification(onSettings: settings)
        let timer = simulateTimerStartedAndPassedDeadline()
        
        await sut.timerDidStart(passed: timer.passed, deadline: timer.deadline)
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_addsTimerPassedItsDeadlineNotificationIfValueExistsAndNotPassedDeadline() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        turnOnTimerPassedItsDeadlineNotification(onSettings: settings)
        let timer = simulateTimerStartedButNotPassedDeadline()
        let expectedDate = Date().addingTimeInterval(timer.deadline - timer.passed)
        let expectedKey = CLOCNotificationSettingKey.timerPassedItsDeadline
        let expectedRequests: [NotificationRequestParamaters] = [
            (
                id: expectedKey.rawValue,
                title: settings.title(forKey: expectedKey),
                body: settings.body(forKey: expectedKey),
                fireDate: expectedDate
            )
        ]
        
        await sut.timerDidStart(passed: timer.passed, deadline: timer.deadline)
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        assertThat(notificationCenter, addedNotificationRequestWithItems: expectedRequests)
    }
    
    // MARK: - Simulate settings changes
    
    private func turnOnTimerPassedItsDeadlineNotification(onSettings settings: MockNotificationSetting) {
        // any number makes this case valid (means turned on)
        settings.timerPassedItsDeadline = 1.minutes

    }
    
    // MARK: - Simulate timer states
    
    // this happens when a user start tracking time on a 'paused' timer
    private func simulateTimerStartedAndPassedDeadline() -> (passed: TimeInterval, deadline: TimeInterval) {
        let timerDeadline = 20.minutes
        let timerPassedTime = timerDeadline + 1
        return (timerPassedTime, timerDeadline)
    }
    
    private func simulateTimerStartedButNotPassedDeadline() -> (passed: TimeInterval, deadline: TimeInterval) {
        let timerDeadline = 20.minutes
        let timerPassedTime = timerDeadline - 2.minutes
        return (timerPassedTime, timerDeadline)
    }
}
