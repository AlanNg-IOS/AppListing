
import UIKit
import KRProgressHUD

protocol GerenalAlertManagerDelegate : AnyObject {
    func didDismiss(viewController : GerenalAlertViewController, animated: Bool, completion: (()->())?, shouldDismiss: Bool)
}

class GerenalAlertManager : UIViewController {
    static let shared : GerenalAlertManager = {
        let manager = GerenalAlertManager()
        manager.loadView()
        return manager
    }()
    
    var window : UIWindow?
    var appWindow : UIWindow?
    
    var viewControllers : [GerenalAlertViewController] = []
    private var loadingsCount : Int = 0
    
    private var loadingVc : GerenalAlertViewController! {
        didSet {
            if oldValue != nil {
                oldValue.delegate = nil
                oldValue.willMove(toParent: nil)
                oldValue.removeFromParent()
                oldValue.view.removeFromSuperview()
                oldValue.didMove(toParent: nil)
            }
            
            loadingVc.willMove(toParent: self)
            loadingVc.view.frame = self.view.bounds
            self.view.addSubview(loadingVc.view)
            self.addChild(loadingVc)
            loadingVc.didMove(toParent: self)
            loadingVc.view.isHidden = true
            
            NSLayoutConstraint.activate([
                loadingVc.view.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                loadingVc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                loadingVc.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                loadingVc.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            ])
        }
    }
    
    override func loadView() {
        setupWindow()
        self.view = UIView(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor.clear
        window?.rootViewController = self
        appWindow = UIApplication.shared.keyWindow
        setupLoading()
    }
    
    private func setupLoading() {
        let alertVc = LoadingAlertViewController.init()
        
        addVc(alertVc)
        self.loadingVc = alertVc
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowLevel = UIWindow.Level(rawValue: 999) // UIWindowLevelAlert
        window?.isOpaque = false
        window?.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0)
    }
    
    func showLoading() {
        if loadingsCount == 0, viewControllers.count == 0 {
            window?.isHidden = false
            addLoading()
        }
        loadingsCount += 1
        
    }
    
    func dismissLoading() {
        loadingsCount -= 1
        if loadingsCount == 0 {
            closeLoading()
            if viewControllers.count > 0 {
                addVc(viewControllers.first!)
            } else {
                self.window?.isHidden = true
            }
        }
    }
    
    func show(vc: GerenalAlertViewController, animated: Bool, completion: (()->())? ) {
        
        self.viewControllers.append(vc)
        vc.delegate = self
        
        if viewControllers.count == 1, loadingsCount == 0 {
            addVc(vc)
            window?.isHidden = false
        }
    }
    
    private func addLoading() {
        loadingVc.view.isHidden = false
    }
    
    private func closeLoading() {
        loadingVc.view.isHidden = true
    }
    
    private func addVc(_ vc: GerenalAlertViewController) {
        vc.willMove(toParent: self)
        vc.view.frame = self.view.bounds
        self.view.addSubview(vc.view)
        self.addChild(vc)
        vc.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            vc.view.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            vc.view.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
        ])
    }
    
}

extension GerenalAlertManager : GerenalAlertManagerDelegate {
    func didDismiss(viewController: GerenalAlertViewController, animated: Bool, completion: (() -> ())?, shouldDismiss: Bool) {
        completion?()
        if shouldDismiss {
            didDismiss(viewController: viewController)
        }
    }
    
    func didDismiss(viewController: GerenalAlertViewController) {
        if let index = viewControllers.firstIndex(where: { vc in
            return vc == viewController
        }) {
            let removeVc = self.viewControllers.remove(at: index)
            removeVc.delegate = nil
            removeVc.willMove(toParent: nil)
            removeVc.view.removeFromSuperview()
            removeVc.removeFromParent()
            removeVc.didMove(toParent: nil)
        }
        if loadingsCount > 0 {
            addLoading()
            return;
        }
        
        if viewControllers.count == 0 {
            self.window?.isHidden = true
        } else {
            addVc(viewControllers.first!)
        }
    }
}
