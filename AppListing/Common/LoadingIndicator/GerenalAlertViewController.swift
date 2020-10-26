
import UIKit

class GerenalAlertViewController: UIViewController {
    
    weak var delegate : GerenalAlertManagerDelegate?
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let delegate = self.delegate {
            delegate.didDismiss(viewController: self, animated: flag, completion: completion, shouldDismiss: true)
            return
        }
        super.dismiss(animated: flag, completion: { [weak self] in
            guard let `self` = self else {
                return
            }
            completion?()
        })
    }


}
