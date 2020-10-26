
import KRProgressHUD

class LoadingIndicator {

    private static var hudCounter = 0 {
        didSet {
            Logger.debug("HUD count: \(LoadingIndicator.hudCounter)")
        }
    }

    static func show() {
        GerenalAlertManager.shared.showLoading()
    }

    static func hide() {
        GerenalAlertManager.shared.dismissLoading()
    }
}
