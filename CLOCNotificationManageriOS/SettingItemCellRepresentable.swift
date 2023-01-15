//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

public protocol SettingItemCellRepresentable {
    var icon: UIImage { get }
    var title: String { get }
    var isOn: Bool { get }
    var subtitle: String? { get }
    var caption: String? { get }
}
