//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit
import ZZNotificationManager
import CLOCNotificationManageriOS

extension CLOCNotificationsViewController {
    var numberOfSections: Int {
        return tableView.numberOfSections
    }
    
    func titleForHeader(InSection section: Int) -> String? {
        let dataSource = tableView.dataSource
        return dataSource?.tableView?(tableView, titleForHeaderInSection: section)
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
        let dataSource = tableView.dataSource
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
}
