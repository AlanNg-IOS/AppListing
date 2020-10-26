
//  Copyright © 2020 SimpleTesting. All rights reserved.

import Foundation
import UIKit

class RecommendListViewModel {
    var data: [RecommendItem] = []
    var displayList: [RecommendItem] = []
    
    init() {
    
    }
    
    func setData(data: [Listing]) {
        self.data = []
        for item in data {
            self.data.append(RecommendItem.init(data: item))
        }
        self.displayList = self.data 
    }
    
    func getRecommendListingData(completion: @escaping () -> ()){
        let request = WebServices.RequestModule.AppListing.getRecommendListing()
                            
        WebServices.requestModel(request: request)
            .subscribe(onNext: { [weak self] (response) in
                guard let data = response.Data else { return }
                guard let feed = data.feed else { return }
                UserDefault.current.recommendListData = feed
                
                self?.setData(data: feed.entry)
                
                completion()
        }, onError: { [weak self] (error) in
            if UserDefault.current.recommendListData != nil{
                self?.setData(data: UserDefault.current.recommendListData?.entry ?? [])
                completion()
            }
        }).disposed(by: appDelegate.disposeBag)
    }
    
    func getFilterList(keyword: String, completion: @escaping () -> ()){
        let key = keyword.lowercased()
        if keyword.count > 0 {
            let filterList = self.data.filter { (item) -> Bool in
                return item.title.lowercased().contains(key) || item.category.lowercased().contains(key) || item.summary.lowercased().contains(key) || item.author.lowercased().contains(key)
            }
            
            self.displayList = filterList
        }else {
            self.displayList = self.data
        }
        completion()
    }
    
}

struct RecommendItem {
    let icon: String
    let title: String
    let category: String
    let summary: String
    let author: String
    
    init(data: Listing) {
        self.icon = data.im_image?.first?.label ?? ""
        self.title = data.name?.label ?? ""
        self.category = data.category?.attributes?.label ?? ""
        self.summary = data.summary?.label ?? ""
        self.author = data.im_artist?.label ?? ""
    }
}


