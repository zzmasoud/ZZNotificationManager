//
//  Copyright © zzmasoud (github.com/zzmasoud).
//


import ZZNotificationManager
import UIKit

final public class CLOCNotificationsUIComposer {
    public typealias SettingItemCellRepresentableClosure = ((_ key: Key) -> SettingItemCellRepresentable)
    public typealias Key = CLOCNotificationSettingKey
    public typealias SectionedKeys = (title: String, keys: [Key])
    weak var delegate: CLOCNotificationsViewControllerDelegate?

    public init(delegate: CLOCNotificationsViewControllerDelegate?) {
        self.delegate = delegate
    }

    public func composedWith(sectionedKeys: [SectionedKeys], cellRepresentable: @escaping SettingItemCellRepresentableClosure, notificationManager: NotificationManager, dateComponentsFormatter: DateComponentsFormatter) -> CLOCNotificationsViewController {
        let notificationsViewController = CLOCNotificationsViewController.makeFromStoryboard()
        notificationsViewController.viewModel = CLOCNotificationsViewModel(tableModels:  mapSectionedKeysToSectionedItems(sectionedKeys, using: cellRepresentable, dateComponentsFormatter: dateComponentsFormatter), notificationAuthorizationCompletion: notificationManager.requestAuthorization(completion:))
        
        return notificationsViewController
    }
    
    private func mapSectionedKeysToSectionedItems(_ sectionedKeys: [SectionedKeys], using cellRepresentable: @escaping SettingItemCellRepresentableClosure, dateComponentsFormatter: DateComponentsFormatter) -> [CLOCNotificationsViewModel.SectionedItems] {
        return sectionedKeys.map({ (title: String, keys: [Key]) in
            let controllers = keys.map { settingKey -> SettingItemCellController in
                let item = cellRepresentable(settingKey)
                let viewModel = SettingItemViewModel<UIImage>(
                    key: settingKey,
                    item: item,
                    delegate: delegate,
                    imageTransformer: { _ in item.icon },
                    durationFormatter: dateComponentsFormatter.string(from:)
                )
                return SettingItemCellController(viewModel: viewModel)
            }
            return (title, controllers)
        })
    }
}

private extension CLOCNotificationsViewController {
    static func makeFromStoryboard() -> CLOCNotificationsViewController {
        let bundle = Bundle(for: CLOCNotificationsViewController.self)
        let storyboard = UIStoryboard(name: "Notifications", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! CLOCNotificationsViewController
    }
}
