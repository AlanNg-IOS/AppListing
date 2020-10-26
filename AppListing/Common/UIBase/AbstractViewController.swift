
import UIKit
import RxSwift

class AbstractViewController: UIViewController {
    var refreshControl = UIRefreshControl()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    @objc func refreshData(_ sender: Any) {
       refreshControl.endRefreshing()
    }
        
    
}
