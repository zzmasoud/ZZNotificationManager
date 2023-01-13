//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager

final class CLOCNotificationsViewController: UITableViewController {
    
    var notificationManager: AsyncNotificationManager?
    var authorizationTask: Task<Bool?, Error>?
    var errorView = UIView()
    var tableData: [[CLOCNotificationSettingKey]] = []
    
    convenience init(notificationManager: AsyncNotificationManager) {
        self.init()
        self.notificationManager = notificationManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        
        authorizationTask = Task { [weak self] in
            guard
                let self = self,
                let notificationManager = self.notificationManager
            else { return false }
            
            do {
                let isAuthorized = try await notificationManager.requestAuthorization()
                self.errorView.isHidden = isAuthorized
                if isAuthorized {
                    self.fillTableData()
                }
                return isAuthorized
            } catch {
                self.errorView.isHidden = false
                throw error
            }
        }
    }
    
    private func fillTableData() {
        tableData = [
            [.timerPassedItsDeadline, .timerPassedTheDuration],
            [.projectDeadlineReached, .noTasksHasBeenAddedSince]
        ]
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
}

class CLOCNotificationsViewControllerTests: XCTestCase {

    func test_init_doesNotAuthorize() {
        let (_, notificationManager) = makeSUT()

        XCTAssertEqual(notificationManager.authorizeCallCount, 0)
    }
    
    func test_viewDidLoad_authorizes() async {
        let (sut, notificationManager) = makeSUT()
        
        await sut.loadViewIfNeeded()
        _ = try? await sut.authorizationTask?.value
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
    }
    
    func test_viewDidLoad_errorViewIsHidden() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.isShowingError)
    }
    
    func test_onRejectedAuthorization_showsErrorView() async {
        let (sut, notificationManager) = makeSUT()
        simulateUserRejectsNotificationAuthorization(notificationManager)

        await sut.loadViewIfNeeded()
        _ = try? await sut.authorizationTask?.value
        
        let isShowingError = await sut.isShowingError
        XCTAssertTrue(isShowingError)
    }
    
    func test_onFailedAuthorization_showsErrorView() async {
        let (sut, notificationManager) = makeSUT()
        simulateFailsNotificationAuthorization(notificationManager)
        
        await sut.loadViewIfNeeded()
        _ = try? await sut.authorizationTask?.value
        
        let isShowingError = await sut.isShowingError
        XCTAssertTrue(isShowingError)
    }
    
    func test_onGrantedAuthorization_showsSettings() async {
        let (sut, notificationManager) = makeSUT()
        simulateGrantsNotificationAuthorization(notificationManager)

        await sut.loadViewIfNeeded()
        let isShowingSettingsBeforeGrantingAuthorization = await sut.isShowingSettings
        XCTAssertFalse(isShowingSettingsBeforeGrantingAuthorization)

        _ = try? await sut.authorizationTask?.value
        let isShowingSettings = await sut.isShowingSettings
        XCTAssertTrue(isShowingSettings)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CLOCNotificationsViewController, notificationManager: NotificationManagerSpy) {
        let notificationManager = NotificationManagerSpy()
        let sut = CLOCNotificationsViewController(notificationManager: notificationManager)
        
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, notificationManager)
    }

    class NotificationManagerSpy: AsyncNotificationManager {
        private(set) var authorizeCallCount: Int = 0
        var authorizationStatus: (Bool, Error?) = (false, nil)

        func requestAuthorization() async throws -> Bool {
            authorizeCallCount += 1
            if let error = authorizationStatus.1 {
                throw error
            } else {
                return authorizationStatus.0
            }
        }
        
        func checkAuthorizationStatus() async -> ZZNotificationAuthStatus {
            fatalError()
        }
        
        func setNotification(forDate: Date, andId id: String, content: UNNotificationContent) async throws {}
    }
    
    func simulateUserRejectsNotificationAuthorization(_ notificationManager: NotificationManagerSpy) {
        notificationManager.authorizationStatus = (false, nil)
    }
    
    func simulateFailsNotificationAuthorization(_ notificationManager: NotificationManagerSpy) {
        notificationManager.authorizationStatus = (true, NSError(domain: "error", code: -1))
    }
    
    func simulateGrantsNotificationAuthorization(_ notificationCenter: NotificationManagerSpy) {
        notificationCenter.authorizationStatus = (true, nil)
    }

}

private extension CLOCNotificationsViewController {
    var numberOfRenderedSettingItemViews: Int {
        let sections = tableView.numberOfSections
        let rows = (0..<sections).reduce(into: 0) { [weak tableView] partialResult, section in
            guard let tableView = tableView else { return }
            partialResult += tableView.numberOfRows(inSection: section)
        }
        return rows
    }
    
    var isShowingSettings: Bool {
        return numberOfRenderedSettingItemViews == CLOCNotificationSettingKey.allCases.count
    }
    
    var isShowingError: Bool {
        return errorView.isHidden == false
    }
}
