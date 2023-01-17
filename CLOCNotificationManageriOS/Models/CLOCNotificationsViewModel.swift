//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

final class CLOCNotificationsViewModel {
    public typealias Observer<T> = (T) -> Void
    public typealias Section = String
    public typealias Item = SettingItemCellController
    public typealias SectionedItems = (section: Section, items: [Item])
    public typealias NotificationAuthorizationCompletion = ((@escaping (Bool, Error?) -> Void) -> ())
    var notificationAuthorizationCompletion: NotificationAuthorizationCompletion
    
    private let tableModels: [SectionedItems]
    private var doneAuthorization: Bool = false
    
    init(tableModels: [SectionedItems], notificationAuthorizationCompletion: @escaping NotificationAuthorizationCompletion) {
        self.tableModels = tableModels
        self.notificationAuthorizationCompletion = notificationAuthorizationCompletion
    }
    
    var onAuhorization: Observer<Bool>?
    var numberOfSections: Int { doneAuthorization ? tableModels.count : 0 }

    func viewLoaded() {
        notificationAuthorizationCompletion({ [weak self] isAuthorized, error in
            self?.doneAuthorization = true
            if let _ = error {
                self?.onAuhorization?(false)
            } else {
                self?.onAuhorization?(isAuthorized)
            }
        })
    }

    func titleForHeader(inSection section: Int) -> String? {
        return tableModels[section].section
    }
    
    func numberOfRows(inSection section: Int) -> Int {
        return tableModels[section].items.count
    }
    
    func cellController(inSection section: Int, row: Int) -> SettingItemCellController {
        return tableModels[section].items[row]
    }
}
