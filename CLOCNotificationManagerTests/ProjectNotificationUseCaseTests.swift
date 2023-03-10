//
//  Copyright © zzmasoud (github.com/zzmasoud).
//  

import XCTest
import ZZNotificationManager

final class ProjectNotificationUseCaseTests: XCTestCase {
    
    func test_addProject_doesNotAddProjectDeadlineNotificationIfValueIsNil() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOffProjectDeadlineNotification(onSettings: settings)
        let project = anyProject()
        
        await sut.addProject(withId: project.id, title: project.title, deadline: project.deadline)

        assertThat(notificationCenter, addedNotificationRequestWithItems: [])
    }
        
    func test_addProject_doesNotAddProjectDeadlineNotificationIfValueIsSonnerThanSetting() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOnProjectDeadlineNotification(onSettings: settings)
        let project = anyProjectWithSonnerDeadline()

        await sut.addProject(withId: project.id, title: project.title, deadline: project.deadline)

        assertThat(notificationCenter, addedNotificationRequestWithItems: [])
    }
    
    func test_addProject_doesNotAddProjectDeadlineNotificationIfValueIsLessThan1DayCloseToSetting() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOnProjectDeadlineNotification(onSettings: settings)
        let project = anyProjectWithExactDeadline()

        await sut.addProject(withId: project.id, title: project.title, deadline: project.deadline)

        assertThat(notificationCenter, addedNotificationRequestWithItems: [])
    }
    
    func test_addProject_addsProjectDeadlineNotificationIfValueIsNotNilAndAvailable() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOnProjectDeadlineNotification(onSettings: settings)
        let key = CLOCNotificationSettingKey.projectDeadlineReached
        let project = anyProject()
        let expectedDate = newDateAfterApplyingTimeSetter(toDate: project.deadline)
        await sut.addProject(withId: project.id, title: project.title, deadline: project.deadline)
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
    
    func test_deleteProject_removesRelatedNotification() async {
        let (sut, notificationCenter, settings) = makeSUT()
        turnOnProjectDeadlineNotification(onSettings: settings)
        let key = CLOCNotificationSettingKey.projectDeadlineReached
        let project = anyProject()
        let expectedDate = newDateAfterApplyingTimeSetter(toDate: project.deadline)
        
        await sut.addProject(withId: project.id, title: project.title, deadline: project.deadline)

        assertThat(notificationCenter, addedNotificationRequestWithItems: [
            (
                id: project.id,
                categoryId: key.rawValue,
                title: settings.title(forKey: key),
                body: settings.body(forKey: key),
                fireDate: expectedDate
            )
        ])
        
        await sut.deleteProjects(withIds: [project.id])
        
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
    
    private func anyProjectWithSonnerDeadline() -> (id: String, deadline: Date, title: String) {
        let (id, deadline, title) = anyProject()
        return (id, deadline.addingTimeInterval(-projectDeadlineReached), title)
    }
    
    private func anyProjectWithExactDeadline() -> (id: String, deadline: Date, title: String) {
        let (id, _, title) = anyProject()
        return (id, Date().addingTimeInterval(projectDeadlineReached).addingTimeInterval(1.minutes), title)
    }
    
    private func newDateAfterApplyingTimeSetter(toDate deadline: Date) -> Date {
        return calendar.date(bySettingHour: projectDeadlineTime.hour, minute: projectDeadlineTime.minute, second: 0, of: deadline)!
            .addingTimeInterval(-projectDeadlineReached)
    }

}
