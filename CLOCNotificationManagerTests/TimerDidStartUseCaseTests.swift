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
    
    func test_timerDidStart_doesNotAddTimerPassedTheDurationNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        settings.timerPassedTheDuration = nil
        
        await sut.timerDidStart()
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }

    func test_timerDidStart_doesNotAddTimerPassedDurationNotificationIfValueExistsAndPassedDuration() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        turnOnTimerPassedDurationNotification(onSettings: settings)
        let timer = simulateTimerStartedAndPassedDuration()
        
        await sut.timerDidStart(passed: timer.passed, duration: timer.duration)
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        XCTAssertEqual(notificationCenter.addedNotificationRequests.count, 0)
    }
    
    func test_timerDidStart_addsTimerPassedDurationNotificationIfValueExistsAndNotPassedDuration() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        turnOnTimerPassedDurationNotification(onSettings: settings)
        let timer = simulateTimerStartedButNotPassedDuration()
        let expectedDate = Date().addingTimeInterval(timer.duration - timer.passed)
        let expectedKey = CLOCNotificationSettingKey.timerPassedTheDuration
        let expectedRequests: [NotificationRequestParamaters] = [
            (
                id: expectedKey.rawValue,
                title: settings.title(forKey: expectedKey),
                body: settings.body(forKey: expectedKey),
                fireDate: expectedDate
            )
        ]
        
        await sut.timerDidStart(passed: timer.passed, duration: timer.duration)
        
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        assertThat(notificationCenter, addedNotificationRequestWithItems: expectedRequests)
    }
    
    func test_timerDidStart_addsTimerPassedDurationAndTimerPassedItsDeadlineNotifications() async {
        let (sut, notificationCenter, settings) = makeSUT()
        let keys: [CLOCNotificationSettingKey] = [.timerPassedTheDuration, .timerPassedItsDeadline]
        turnOnTimerPassedDurationNotification(onSettings: settings)
        turnOnTimerPassedItsDeadlineNotification(onSettings: settings)
        let timer = simulateTimerStartedButNotPassedDurationAndItsDeadline()
        // here order is important, if changed will fails. how to fix it?
        let expectedKeys: [CLOCNotificationSettingKey] = [.timerPassedItsDeadline, .timerPassedTheDuration]
        let expectedRequests: [NotificationRequestParamaters] = expectedKeys.map { key in
            var expectedDate = Date().addingTimeInterval(timer.duration - timer.passed)
            if key == .timerPassedItsDeadline {
                expectedDate = Date().addingTimeInterval(timer.deadline - timer.passed)
            }
            return (
                id: key.rawValue,
                title: settings.title(forKey: key),
                body: settings.body(forKey: key),
                fireDate: expectedDate
            )
        }
        
        await sut.timerDidStart(passed: timer.passed, deadline: timer.deadline, duration: timer.duration)
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: keys.map { $0.rawValue} )
        assertThat(notificationCenter, addedNotificationRequestWithItems: expectedRequests)
    }
    
    // MARK: - Simulate settings changes
    
    var duration: TimeInterval { return 15.minutes }
    
    private func turnOnTimerPassedItsDeadlineNotification(onSettings settings: MockNotificationSetting) {
        // any number makes this case valid (means turned on)
        settings.timerPassedItsDeadline = 1.minutes

    }
    
    private func turnOnTimerPassedDurationNotification(onSettings settings: MockNotificationSetting) {
        settings.timerPassedItsDeadline = duration
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
    
    private func simulateTimerStartedAndPassedDuration() -> (passed: TimeInterval, duration: TimeInterval) {
        let settedDuration = duration
        let timerPassedTime = settedDuration + 1
        return (timerPassedTime, settedDuration)
    }
    
    private func simulateTimerStartedButNotPassedDuration() -> (passed: TimeInterval, duration: TimeInterval) {
        let settedDuration = duration
        let timerPassedTime = settedDuration - 2.minutes
        return (timerPassedTime, settedDuration)
    }
    
    private func simulateTimerStartedButNotPassedDurationAndItsDeadline() -> (passed: TimeInterval, duration: TimeInterval, deadline: TimeInterval) {
        let settedDuration = duration
        let timerDeadline = settedDuration + 30.minutes
        let timerPassedTime = settedDuration - 5.minutes
        return (timerPassedTime, settedDuration, timerDeadline)
    }
}
