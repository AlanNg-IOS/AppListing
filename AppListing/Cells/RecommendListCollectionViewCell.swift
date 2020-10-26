
//  Copyright © 2020 SimpleTesting. All rights reserved.

import UIKit

class RecommendListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imvIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    
    var recommendListViewModel: RecommendItem! {
        didSet {
            Utilities.shared.getImage(url: recommendListViewModel.icon) { [weak self] (image) in
                self?.imvIcon.image = image
                self?.imvIcon.layoutIfNeeded()
                self?.imvIcon.layer.roundedCorner()
            }
            lblTitle.text = recommendListViewModel.title
            lblCategory.text = recommendListViewModel.category
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
