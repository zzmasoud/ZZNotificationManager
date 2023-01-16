//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

// MARK: - UISwitch + Simulate

extension UISwitch {
    func simulateToggle() {
        self.setOn(!self.isOn, animated: false) // triggering bottom targets don't change the value (isOn).
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ selector in
                (target as NSObject).perform(Selector(selector))
            })
        })
    }
}

// MARK: - UIButton + Simulate

extension UIButton {
    func simulateTap() {
        self.allTargets.forEach({ target in
            self.actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach({ selector in
                (target as NSObject).perform(Selector(selector))
            })
        })
    }
}
