//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public protocol CLOCNotificationsViewControllerDelegate: AnyObject {
    func didToggle(key: CLOCNotificationsUIComposer.Key, value: Bool)
    func didTapToChangeTime(key: CLOCNotificationsUIComposer.Key)
}

final public class CLOCNotificationsViewController: UITableViewController {

    var viewModel: CLOCNotificationsViewModel! // is it make sense to force unwrap?
    private(set) public var errorView = UIView()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewLoaded()
        
        viewModel.onAuhorization = { [weak self] isGranted in
            self?.errorView.isHidden = isGranted
            self?.tableView.reloadData()
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(inSection: section)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellController(inSection: indexPath.section, row: indexPath.row).view(in: tableView)
    }
}
