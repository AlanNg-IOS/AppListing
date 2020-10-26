
import UIKit
import KRProgressHUD

class LoadingAlertViewController: GerenalAlertViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func loadView() {
        super.loadView()
        self.view = UIView()
        KRProgressHUD.appearance().activityIndicatorColors = [.white, .LightGrey]
        KRProgressHUD.appearance().style = .custom(background: .clear, text: .clear, icon: .white)
        KRProgressHUD.showOn(self).show()
        
    }
    
}
