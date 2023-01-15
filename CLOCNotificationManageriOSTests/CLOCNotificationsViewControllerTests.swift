//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import XCTest
import ZZNotificationManager
import CLOCNotificationManageriOS

final class CLOCNotificationsViewController: UITableViewController {
    
    var notificationManager: NotificationManager?
    var errorView = UIView()
    var tableData: [[CLOCNotificationSettingKey]] = []
    
    convenience init(notificationManager: NotificationManager) {
        self.init()
        self.notificationManager = notificationManager
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        
        notificationManager?.requestAuthorization(completion: { [weak self] isAuthorized, error in
            guard error == nil else {
                self?.errorView.isHidden = false
                return
            }
            guard let self = self else { return }
            
            self.errorView.isHidden = isAuthorized
            if isAuthorized {
                self.fillTableData()
            }
        })
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
    
    func test_viewDidLoad_authorizes() {
        let (sut, notificationManager) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(notificationManager.authorizeCallCount, 1)
    }
    
    func test_viewDidLoad_errorViewIsHidden() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertFalse(sut.isShowingError)
    }
    
    func test_onRejectedAuthorization_showsErrorView() {
        let (sut, notificationManager) = makeSUT()

        sut.loadViewIfNeeded()
        simulateUserRejectsNotificationAuthorization(notificationManager)
        
        XCTAssertTrue(sut.isShowingError)
    }
    
    func test_onFailedAuthorization_showsErrorView() {
        let (sut, notificationManager) = makeSUT()
        
        sut.loadViewIfNeeded()
        simulateFailsNotificationAuthorization(notificationManager)

        XCTAssertTrue(sut.isShowingError)
    }
    
    func test_onGrantedAuthorization_showsSettings() {
        let (sut, notificationManager) = makeSUT()

        sut.loadViewIfNeeded()
        simulateGrantsNotificationAuthorization(notificationManager)

        XCTAssertTrue(sut.isShowingSettings)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CLOCNotificationsViewController, notificationManager: NotificationManagerSpy) {
        let notificationManager = NotificationManagerSpy()
        let sut = CLOCNotificationsViewController(notificationManager: notificationManager)
        
        trackForMemoryLeaks(notificationManager, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, notificationManager)
    }

    class NotificationManagerSpy: NotificationManager {
        var authorizationStatus: [(Bool, Error?) -> Void] = []
        var authorizeCallCount: Int { authorizationStatus.count }

        func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
            authorizationStatus.append(completion)
        }
        
        func checkAuthorizationStatus(completion: @escaping AuthorizationStatusCompletion) {
            fatalError()
        }
        
        func setNotification(forDate: Date, andId id: String, content: UNNotificationContent, completion: @escaping SetNotificationCompletion) {
            fatalError()
        }

        func removePendingNotifications(withIds: [String]) {
            fatalError()
        }
    }
    
    func simulateUserRejectsNotificationAuthorization(_ notificationManager: NotificationManagerSpy) {
        notificationManager.authorizationStatus[0](false, nil)
    }
    
    func simulateFailsNotificationAuthorization(_ notificationManager: NotificationManagerSpy) {
        notificationManager.authorizationStatus[0](true, NSError(domain: "error", code: -1))
    }
    
    func simulateGrantsNotificationAuthorization(_ notificationCenter: NotificationManagerSpy) {
        notificationCenter.authorizationStatus[0](true, nil)
    }

}

private extension CLOCNotificationsViewController {
    var numberOfSections: Int {
        return tableView.numberOfSections
    }

    var numberOfRenderedSettingItemViews: Int {
        let sections = numberOfSections
        let rows = (0..<sections).reduce(into: 0) { [weak tableView] partialResult, section in
            guard let tableView = tableView else { return }
            partialResult += tableView.numberOfRows(inSection: section)
        }
        return rows
    }
    
    var isShowingSettings: Bool {
        return numberOfSections == 2 && numberOfRenderedSettingItemViews == CLOCNotificationSettingKey.allCases.count
    }
    
    var isShowingError: Bool {
        return errorView.isHidden == false
    }
    
    func settingItemView(at indexPath: IndexPath) -> UITableViewCell? {
        return tableView.cellForRow(at: indexPath)
    }
}
