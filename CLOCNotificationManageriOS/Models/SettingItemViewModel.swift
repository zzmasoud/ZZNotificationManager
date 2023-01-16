//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

final class SettingItemViewModel {
    typealias Observer<T> = (T)->Void

    private let key: CLOCNotificationsUIComposer.Key
    private let item: SettingItemCellRepresentable
    private let delegate: CLOCNotificationsViewControllerDelegate?

    init(key: CLOCNotificationsUIComposer.Key, item: SettingItemCellRepresentable, delegate: CLOCNotificationsViewControllerDelegate?) {
        self.key = key
        self.item = item
        self.delegate = delegate
    }
    
    var onSwitchToggle: Observer<Bool>?
    
    var icon: UIImage { item.icon }
    var title: String { item.title }
    var isOn: Bool { item.isOn }
    var subtitle: String? { item.subtitle }
    var hasSubtitle: Bool { subtitle != nil }
    var caption: String? { item.caption }
    var hasCaption: Bool { caption != nil }
    var isChangeTimeButtonEnabled: Bool { isOn }
    
    func toggle(isOn: Bool) {
        onSwitchToggle?(isOn)
        delegate?.didToggle(key: key, value: isOn)
    }
    
    func changeTime() {
        delegate?.didTapToChangeTime(key: key)
    }
}
