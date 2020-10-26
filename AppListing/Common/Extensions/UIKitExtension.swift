
import UIKit
import WebKit

extension UIColor {
    static func fromHex(hex:String, alpha:CGFloat = 1.0) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}

extension UIImage {
    public func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        return self.resized(toWidth: canvasSize.width)
    }
    
    public func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    public func fixedOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform : CGAffineTransform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -CGFloat.pi / 2)
            break
        default:
            break
        }
        
        switch self.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx : CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: (self.cgImage?.bitsPerComponent)!,
                                        bytesPerRow: 0, space: (self.cgImage?.colorSpace)!, bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!)!
        
        ctx.concatenate(transform)
        
        switch self.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg : CGImage = ctx.makeImage()!
        let img : UIImage = UIImage.init(cgImage: cgimg)
        return img
    }
    
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        
        return imageData.base64EncodedString()
    }
    
    func resizedByMB(size:Double = 10.0) -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        self.stackOverflowAnswer()
        let megaByte = 1024.0
        let maxSize = size * megaByte * megaByte
        
        var resizingImage = self
        var imageSize = Double(imageData.count)
        
        while imageSize > maxSize {
            guard let resizedImage = resizingImage.resized(withPercentage: 0.9),
            let imageData = resizedImage.pngData() else { return nil }

            resizingImage = resizedImage
            imageSize = Double(imageData.count)
        }
        resizingImage.stackOverflowAnswer()
        return resizingImage
    }
    
    func stackOverflowAnswer() {
        if let data = self.pngData() as Data? {
      print("There were \(data.count) bytes")
      let bcf = ByteCountFormatter()
      bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
      bcf.countStyle = .file
      let string = bcf.string(fromByteCount: Int64(data.count))
      print("formatted result: \(string)")
      }
    }
    
}

extension CALayer {
    public func applyShadow(color: UIColor = UIColor.lightGray, shadowRadius: CGFloat = 15) {
        self.shadowColor = color.cgColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = CGSize(width: 2, height: 2)
        self.shadowOpacity = 0.8
    }
    
    public func clipWithCircle() {
        self.cornerRadius = self.frame.height / 2
        self.masksToBounds = true
    }
    
    public func roundedCorner() {
        self.cornerRadius = self.frame.height / 4
        self.masksToBounds = true
    }
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
    
}

extension UILabel {
    public func setTextWithKerning(text: String?, kerning: Float) {
        guard let text = text else {
            self.text = nil
            return
        }
        
        let attr = [NSAttributedString.Key.kern: NSNumber(value: kerning)]
        self.attributedText = NSAttributedString(string: text, attributes: attr)
    }
    
    public func applyKerning(_ kerning: Float) {
        self.setTextWithKerning(text: self.text, kerning: kerning)
    }
    
    public func setHtmlText(_ html:String?) {
        if let htmlData = html?.data(using: .utf16, allowLossyConversion: false),
            let htmlAttriubtedText = try? NSAttributedString(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            
            let mutatedHtmlAttriubtedText = htmlAttriubtedText.mutableCopy() as! NSMutableAttributedString
            let fontAttrRange = NSRange(location: 0, length: htmlAttriubtedText.length)
            mutatedHtmlAttriubtedText.setAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], range: fontAttrRange)
            self.attributedText = mutatedHtmlAttriubtedText
        } else {
            self.text = nil
        }
    }
    
    public func setBorder(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
}

extension NSTextAttachment {
    static func getCenteredImageAttachment(with image: UIImage?, and
    font: UIFont?) -> NSTextAttachment? {
        let imageAttachment = NSTextAttachment()
    guard let image = image,
        let font = font else { return nil }

    imageAttachment.bounds = CGRect(x: 0, y: (font.capHeight - image.size.height).rounded() / 2, width: image.size.width, height: image.size.height)
    imageAttachment.image = image
    return imageAttachment
    }
}

private var closureKey: Void?
typealias ButtonAction = @convention(block) () -> ()
extension UIButton {
    
    func setUnderlineTitle(for state: UIControl.State) {
        guard let text = self.title(for: state) else { return }
        
        let underlineAttr = [NSAttributedString.Key.underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)]
        let attrString = NSMutableAttributedString(string: text, attributes: underlineAttr)
        self.setAttributedTitle(attrString, for: .normal)
    }
    
    @objc func callActionClosure() {
        let closureObject: AnyObject = objc_getAssociatedObject(self, &closureKey) as AnyObject
        let closure = unsafeBitCast(closureObject, to: ButtonAction.self)
        closure()
    }
    
    func actionHandle(controlEvents event :UIControl.Event, forAction action:ButtonAction? = nil) {
        if let theAction = action{
            let dealObject: AnyObject = unsafeBitCast(theAction, to: AnyObject.self)
            objc_setAssociatedObject(self, &closureKey, dealObject, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            self.addTarget(self, action: #selector(UIButton.callActionClosure), for: event)
        }
        
    }
    
}

var closureDict: [String : (() -> Void)] = [:]
extension UIView {
    fileprivate func blockTouch(NumberOfTouche touchNumbers: Int, NumberOfTaps tapNumbers: Int) {
        let tapGesture = UITapGestureRecognizer()
        //        tapGesture.numberOfTouchesRequired = touchNumbers
        tapGesture.numberOfTapsRequired = tapNumbers
        tapGesture .addTarget(self, action: #selector(UIView.tapActions))
        self.addGestureRecognizer(tapGesture)
    }
    
    func callback(_ action :@escaping (() -> Void)) {
        _addBlock(NewAction: action)
        blockTouch(NumberOfTouche: 1, NumberOfTaps: 1)
    }
    
    @objc func tapActions() {
        _excuteCurrentBlock()
    }
    
    fileprivate func _addBlock(NewAction newAction:@escaping () -> Void) {
        let key = String(describing: NSValue(nonretainedObject: self))
        closureDict[key] = newAction
    }
    
    fileprivate func _excuteCurrentBlock() {
        let key = String(describing: NSValue(nonretainedObject: self))
        let block = closureDict[key]
        block!()
    }

}

extension UITextField {
    
    public func appleLeftPadding(padding:CGFloat) {
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: padding, height: self.frame.height)))
    }
    
    func clearButtonWithImage(_ image: UIImage,
                              _ imageColor: UIColor = UIColor.white,
                              _ isAlwaysVisible: Bool = true) {
        let clearButton = UIButton()
        clearButton.tintColor = imageColor
        let coloredImage = image.withRenderingMode(.alwaysTemplate)
        clearButton.setImage(coloredImage, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(self.clear(sender:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = isAlwaysVisible ? .always : .never
    }
    
    @objc func clear(sender: AnyObject) {
        self.text = ""
        NotificationCenter.default.post(name: Notification.Name(rawValue: "ClearText"), object: nil)
    }
}

extension UIApplication {
    
    public class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
}

extension UILabel {
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0, textAligment:NSTextAlignment = .left) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.alignment = textAligment
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        // Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}

extension UITableViewCell {
    class func cellReuseIdentifier() -> String {
        return "\(self)"
    }
    
}


extension UIViewController {
    /**
     
     *Config the present view need Dismiss button (default is True)*
     
     */
    
    func getClassName() -> String {
        return String(describing: type(of: self))
    }
    
    var isPresentWithDismissButton:Bool {
        return true
    }
    
    @IBAction func actionDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showErrorAlert(error:Error, title:String = "Error") {
        
    }
    
    func showAlert(title:String?, message:String, leftBtnTitle: String? = nil , rightBtnTitle: String = "OK", completionHandler: @escaping ((Bool)->Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let leftbutton = leftBtnTitle {
            alert.addAction(UIAlertAction(title: leftbutton, style: .default, handler: { (_) -> Void in
                completionHandler(true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: rightBtnTitle, style: .cancel, handler: { (_) -> Void in
            completionHandler(false)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let contentView = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layoutAttachAll()
        return contentView
    }
    
    private func layoutAttachAll(margin : CGFloat = 0.0) {
        let view = superview
        layoutAttachTop(to: view, margin: margin)
        layoutAttachBottom(to: view, margin: margin)
        layoutAttachLeading(to: view, margin: margin)
        layoutAttachTrailing(to: view, margin: margin)
    }
    
    @discardableResult
    private func layoutAttachTop(to: UIView? = nil, margin : CGFloat = 0.0) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = view == superview
        let constraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: isSuperview ? .top : .bottom, multiplier: 1.0, constant: margin)
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    /// attaches the bottom of the current view to the given view
    @discardableResult
    private func layoutAttachBottom(to: UIView? = nil, margin : CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: isSuperview ? .bottom : .top, multiplier: 1.0, constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    /// attaches the leading edge of the current view to the given view
    @discardableResult
    private func layoutAttachLeading(to: UIView? = nil, margin : CGFloat = 0.0) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: isSuperview ? .leading : .trailing, multiplier: 1.0, constant: margin)
        superview?.addConstraint(constraint)
        
        return constraint
    }
    
    /// attaches the trailing edge of the current view to the given view
    @discardableResult
    private func layoutAttachTrailing(to: UIView? = nil, margin : CGFloat = 0.0, priority: UILayoutPriority? = nil) -> NSLayoutConstraint {
        
        let view: UIView? = to ?? superview
        let isSuperview = (view == superview) || false
        let constraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: isSuperview ? .trailing : .leading, multiplier: 1.0, constant: -margin)
        if let priority = priority {
            constraint.priority = priority
        }
        superview?.addConstraint(constraint)
        
        return constraint
    }
    // Round corner
    func roundedTopLeft(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }

    func roundedTopRight(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedBottomLeft(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedBottomRight(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomRight],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedBottom(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomRight , .bottomLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedTop(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .topLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedLeft(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedRight(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .bottomRight],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    func roundedAllCorner(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topRight , .bottomRight , .topLeft , .bottomLeft],
                                     cornerRadii: CGSize(width: 15, height: 15))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
