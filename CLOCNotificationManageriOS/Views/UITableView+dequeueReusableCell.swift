//
//  Copyright © zzmasoud (github.com/zzmasoud).
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let id = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: id) as! T
    }
}

