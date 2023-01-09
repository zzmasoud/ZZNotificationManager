//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

final class ProjectNotificationUseCaseTests: XCTestCase {
    
    func test_projectDidAdd_doesNotAddProjectDeadlineNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOffProjectDeadlineNotification(onSettings: settings)
        let project = anyProject()
        
        await sut.projectDidAdd(deadline: project.deadline, title: project.title, id: project.id)
        
        assertThat(notificationCenter, addedNotificationRequestWithItems: [])
    }
    
    func test_projectDidAdd_addsProjectDeadlineNotificationIfValueIsNotNilAndAvailable() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOnProjectDeadlineNotification(onSettings: settings)
        let key = CLOCNotificationSettingKey.projectDeadlineReached
        let project = anyProject()
        let expectedDate = newDateAfterApplyingTimeSetter(toDate: project.deadline)
        await sut.projectDidAdd(deadline: project.deadline, title: project.title, id: project.id)
        assertThat(notificationCenter, addedNotificationRequestWithItems: [
            (
                id: project.id,
                categoryId: key.rawValue,
                title: settings.title(forKey: key),
                body: settings.body(forKey: key),
                fireDate: expectedDate
            )
        ])
    }
    
    func test_projectDidDelete_removesRelatedNotification() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOnProjectDeadlineNotification(onSettings: settings)
        let key = CLOCNotificationSettingKey.projectDeadlineReached
        let project = anyProject()
        let expectedDate = newDateAfterApplyingTimeSetter(toDate: project.deadline)
        
        await sut.projectDidAdd(deadline: project.deadline, title: project.title, id: project.id)
        assertThat(notificationCenter, addedNotificationRequestWithItems: [
            (
                id: project.id,
                categoryId: key.rawValue,
                title: settings.title(forKey: key),
                body: settings.body(forKey: key),
                fireDate: expectedDate
            )
        ])
        
        await sut.projectDidDelete(id: project.id)
        assertThat(notificationCenter, deletedNotificationRequestsWithIds: [project.id])
    }
    
    // MARK: - Simulate settings changes

    private func turnOffProjectDeadlineNotification(onSettings settings: MockNotificationSetting) {
        settings.projectDeadlineReached = nil
    }
    
    private func turnOnProjectDeadlineNotification(onSettings settings: MockNotificationSetting) {
        settings.projectDeadlineReached = projectDeadlineReached

    }
    
    private var projectDeadlineReached: TimeInterval { return 7.days }
    
    // MARK: - Project
    
    private func anyProject() -> (id: String, deadline: Date, title: String) {
        let id = UUID().uuidString
        let deadline = Date()
            .addingTimeInterval(projectDeadlineReached) // to make it equal to actual deadline setting
            .addingTimeInterval(3.days) // to make it later that actual deadline setting
        let title = "Project-X"
        return (id, deadline, title)
    }
    
    private func anyProjectWithSoonerDeadline() -> (id: String, deadline: Date, title: String) {
        let (id, deadline, title) = anyProject()
        return (id, deadline.addingTimeInterval(-1.days), title)
    }
    
    private func newDateAfterApplyingTimeSetter(toDate deadline: Date) -> Date {
        return calendar.date(bySettingHour: projectDeadlineTime.hour, minute: projectDeadlineTime.minute, second: 0, of: deadline)!
            .addingTimeInterval(-projectDeadlineReached)
    }

}
