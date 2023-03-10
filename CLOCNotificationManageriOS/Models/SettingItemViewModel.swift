//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

final class SettingItemViewModel<Image> {
    typealias Observer<T> = (T)->Void
    public typealias ImageTransformer = (Any) -> Image
    public typealias DurationFormatter = (Double) -> String?

    private let key: CLOCNotificationsUIComposer.Key
    private let item: SettingItemCellRepresentable
    private let delegate: CLOCNotificationsViewControllerDelegate?
    private let imageTransformer: ImageTransformer
    private let durationFormatter: DurationFormatter

    init(key: CLOCNotificationsUIComposer.Key, item: SettingItemCellRepresentable, delegate: CLOCNotificationsViewControllerDelegate?, imageTransformer: @escaping ImageTransformer, durationFormatter: @escaping DurationFormatter) {
        self.key = key
        self.item = item
        self.delegate = delegate
        self.imageTransformer = imageTransformer
        self.durationFormatter = durationFormatter
    }
    
    var onSwitchToggle: Observer<Bool>?
    
    var icon: Image { imageTransformer(item.icon) }
    var title: String { item.title }
    var isOn: Bool { item.isOn }
    var subtitle: String? { item.subtitle }
    var hasSubtitle: Bool { subtitle != nil }
    var caption: String? { item.caption }
    var hasCaption: Bool { caption != nil }
    var isChangeTimeButtonEnabled: Bool { isOn }
    var changeTimeButtonTitle: String? { durationFormatter(item.duration) }
    
    func toggle(isOn: Bool) {
        onSwitchToggle?(isOn)
        delegate?.didToggle(key: key, value: isOn)
    }
    
    func changeTime() {
        delegate?.didTapToChangeTime(key: key)
    }
}
