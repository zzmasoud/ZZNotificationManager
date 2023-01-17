//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public protocol CLOCNotificationsViewControllerDelegate: AnyObject {
    func didToggle(key: CLOCNotificationsUIComposer.Key, value: Bool)
    func didTapToChangeTime(key: CLOCNotificationsUIComposer.Key)
}

final public class CLOCNotificationsViewController: UITableViewController {
    public typealias Section = String
    public typealias Item = SettingItemCellController
    public typealias SectionedItems = (section: Section, items: [Item])
    public typealias NotificationAuthorizationCompletion = ((@escaping (Bool, Error?) -> Void) -> ())

    var tableModels: [SectionedItems] = []
    var notificationAuthorizationCompletion: NotificationAuthorizationCompletion?
    private(set) public var errorView = UIView()
        
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.isHidden = true
        tableView.dataSource = nil
        tableView.delegate = self
        
        notificationAuthorizationCompletion?({ [weak self] isAuthorized, error in
            guard let self = self else { return }
            guard error == nil else { return self.errorView.isHidden = false }
            
            self.errorView.isHidden = isAuthorized
            if isAuthorized {
                self.fillTableData()
            }
        })
    }
    
    private func fillTableData() {
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableModels[section].section
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels[section].items.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableModels[indexPath.section].items[indexPath.row].view(in: tableView)
    }
}
