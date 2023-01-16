//
//  Copyright © zzmasoud (github.com/zzmasoud).
//


import ZZNotificationManager

final public class CLOCNotificationsUIComposer {
    public typealias SettingItemCellRepresentableClosure = ((_ key: Key) -> SettingItemCellRepresentable)
    public typealias Key = CLOCNotificationSettingKey
    public typealias SectionedKeys = (title: String, keys: [Key])
    weak var delegate: CLOCNotificationsViewControllerDelegate?

    public init(delegate: CLOCNotificationsViewControllerDelegate?) {
        self.delegate = delegate
    }

    public func composedWith(sectionedKeys: [SectionedKeys], cellRepresentable: @escaping SettingItemCellRepresentableClosure, notificationManager: NotificationManager) -> CLOCNotificationsViewController {
        let notificationsViewController = CLOCNotificationsViewController(
            tableModels:
                mapSectionedKeysToSectionedItems(
                    sectionedKeys,
                    using: cellRepresentable
                ),
            notificationAuthorizationCompletion:
                notificationManager.requestAuthorization(completion:)
        )
        
        return notificationsViewController
    }
    
    private func mapSectionedKeysToSectionedItems(_ sectionedKeys: [SectionedKeys], using cellRepresentable: @escaping SettingItemCellRepresentableClosure) -> [CLOCNotificationsViewController.SectionedItems] {
        return sectionedKeys.map({ (title: String, keys: [Key]) in
            let controllers = keys.map { settingKey -> SettingItemCellController in
                let item = cellRepresentable(settingKey)
                let viewModel = SettingItemViewModel(key: settingKey, item: item, delegate: delegate)
                return SettingItemCellController(viewModel: viewModel)
            }
            return (title, controllers)
        })
    }
}
