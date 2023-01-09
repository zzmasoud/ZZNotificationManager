//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

final class ProjectNotificationUseCaseTests: XCTestCase {
    
    func test_projectDidAdd_doesNotAddProjectDeadlineNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOffProjectDeadlineNotification(onSettings: settings)
        let deadline = Date().addingTimeInterval(10.days)
        let title = "Project-X"
        let id = UUID().uuidString
        
        await sut.projectDidAdd(deadline: deadline, title: title, id: id)
        
        assertThat(notificationCenter, addedNotificationRequestWithItems: [])
    }
    
    func test_projectDidAdd_addsProjectDeadlineNotificationIfValueIsNotNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOnProjectDeadlineNotification(onSettings: settings)
        let deadline = Date().addingTimeInterval(10.days)
        let title = "Project-X"
        let id = UUID().uuidString
        let key = CLOCNotificationSettingKey.projectDeadlineReached
        let expectedDate = deadline
        
        await sut.projectDidAdd(deadline: deadline, title: title, id: id)

        assertThat(notificationCenter, addedNotificationRequestWithItems: [
            (
                id: id,
                categoryId: key.rawValue,
                title: settings.title(forKey: key),
                body: settings.body(forKey: key),
                fireDate: expectedDate
            )
        ])
    }
    
    // MARK: - Simulate settings changes

    private func turnOffProjectDeadlineNotification(onSettings settings: MockNotificationSetting) {
        settings.projectDeadlineReached = nil
    }
    
    
    private func turnOnProjectDeadlineNotification(onSettings settings: MockNotificationSetting) {
        settings.projectDeadlineReached = 10.days

    }
}
