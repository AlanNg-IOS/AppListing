
//  Copyright © 2020 SimpleTesting. All rights reserved.

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPosition: UILabel!
    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var vwRating: UIView!
    
    var listViewModel: ListItem! {
        didSet {
            lblPosition.text = "\(listViewModel.position)"
            Utilities.shared.getImage(url: listViewModel.icon) { [weak self] (image) in
                self?.imvIcon.image = image
                self?.imvIcon.layoutIfNeeded()
                let index = self?.listViewModel.position ?? 0
                if index % 2 == 1 {
                    self?.imvIcon.layer.roundedCorner()
                } else {
                    self?.imvIcon.layer.clipWithCircle()
                }
                self?.imvIcon.layer.borderWidth = 1
                self?.imvIcon.layer.borderColor = UIColor.LightGrey.cgColor
            }
            lblTitle.text = listViewModel.title
            lblCategory.text = listViewModel.category
            for view in vwRating.subviews{
                view.removeFromSuperview()
            }
            vwRating.addSubview(listViewModel.getRatingView())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
