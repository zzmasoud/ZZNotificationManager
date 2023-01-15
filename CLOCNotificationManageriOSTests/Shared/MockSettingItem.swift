//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import CLOCNotificationManageriOS
import UIKit

struct MockSettingItem: SettingItemCellRepresentable {
    var icon: UIImage
    var title: String
    var isOn: Bool
    var subtitle: String?
    var caption: String?
}
