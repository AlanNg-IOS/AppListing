
import UIKit

class ListViewController: AbstractViewController {

    @IBOutlet weak var sbrListing: UISearchBar!
    @IBOutlet weak var cvRecommendList: UICollectionView!
    @IBOutlet weak var tbvList: UITableView!
    
    var recommendListObject = RecommendListViewModel()
    var listObject = ListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        sbrListing.delegate = self
        setupTableView()
        setupCollectionView()
        listObject.getListingData { [weak self] in
            self?.listObject.loadListData {
                self?.tbvList.reloadData()
            }
        }
        recommendListObject.getRecommendListingData { [weak self] in
            self?.cvRecommendList.reloadData()
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchBarSearchButtonClicked))
        view.addGestureRecognizer(tap)
    }
    
    func setupTableView() {
        tbvList.delegate = self
        tbvList.dataSource = self
        tbvList.tableFooterView = UIView()
        tbvList.estimatedRowHeight = 100
    }

    func setupCollectionView(){
        cvRecommendList.register(UINib(nibName: "RecommendListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecommendListCollectionViewCell")
        
        guard let collectionLayout = cvRecommendList.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        collectionLayout.itemSize = CGSize.init(width: (AppConstant.screenWidth - 4*8.0)/3.0, height: 200)
        collectionLayout.scrollDirection = .horizontal
        
        collectionLayout.minimumLineSpacing = (AppConstant.screenWidth - (collectionLayout.itemSize.width*3.5))/3.5
        
        cvRecommendList.delegate = self
        cvRecommendList.dataSource = self
        cvRecommendList.showsVerticalScrollIndicator = false
        cvRecommendList.showsHorizontalScrollIndicator = false
        cvRecommendList.clipsToBounds = true
        
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollOffset = scrollView.contentOffset
        let cvAvailableContentOffset = cvRecommendList.contentSize.width - cvRecommendList.bounds.size.width
        let tbvAvailableContentOffset = tbvList.contentSize.height - tbvList.bounds.height
        
        if self.tbvList == scrollView {
            var scrollRange = scrollOffset.y
            scrollRange = cvAvailableContentOffset * scrollRange / tbvAvailableContentOffset
            if scrollRange < 0 {
                scrollRange = 0
            } else if scrollRange >= cvAvailableContentOffset{
                scrollRange = cvAvailableContentOffset
            }
            self.cvRecommendList.setContentOffset(CGPoint.init(x: scrollRange, y: 0), animated: true)
        }
    }

}

extension ListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendListObject.displayList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendListCollectionViewCell", for: indexPath) as? RecommendListCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.recommendListViewModel = recommendListObject.displayList[indexPath.row]
        return cell
    }
    
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listObject.displayList.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.item + 1 == listObject.numberOfItems) && ((indexPath.item + 1) % listObject.numberOfPagination == 0) {
            if listObject.hasMoreItems {
                listObject.loadListData {
                    self.tbvList.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = Utilities.shared.dequeueReusableTableViewCell(withNibName: "ListTableViewCell", for: tableView) as? ListTableViewCell else {
            return UITableViewCell()
        }
        cell.listViewModel = listObject.displayList[indexPath.row]
        
        return cell
    }
}

extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        recommendListObject.getFilterList(keyword: searchText) {
            self.cvRecommendList.reloadData()
        }
        listObject.getFilterList(keyword: searchText) {
            self.tbvList.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }

}


