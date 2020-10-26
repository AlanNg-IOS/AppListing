
//  Copyright © 2020 SimpleTesting. All rights reserved.

import Foundation
import UIKit
import Cosmos

class ListViewModel {
    var data: [ListItem] = []
    
    var displayList: [ListItem] = []
    
    let numberOfPagination = 10
    var currentPage = 0
    
    var hasMoreItems: Bool {
        get {
            let count = data.count - displayList.count
            if count > 0 {
                return true
            }
            return false
        }
    }
    
    var numberOfItems: Int {
        get {
            return displayList.count
        }
    }
    
    init() {
    
    }
    
    func setData(data: [Listing]) {
        self.data = []
        for (index,item) in data.enumerated() {
            var itemData = ListItem.init(data: item)
            itemData.position = index + 1
            self.data.append(itemData)
        }
    }
    
    func updateData(data: ItemDetail, completion: @escaping () -> ()){
        for (index,item) in self.data.enumerated() {
            if item.id == data.trackId {
                self.data[index].rating = data.averageUserRating
                self.data[index].numOfAdvices = "(\(data.userRatingCount))"
                self.displayList[index].rating = data.averageUserRating
                self.displayList[index].numOfAdvices = "(\(data.userRatingCount))"
                completion()
                break
            }
        }
    }
    
    func getListingData(completion: @escaping () -> ()){
        let request = WebServices.RequestModule.AppListing.getFreeListing()
                            
        WebServices.requestModel(request: request)
            .subscribe(onNext: { [weak self] (response) in
                guard let data = response.Data else { return }
                guard let feed = data.feed else { return }
                UserDefault.current.listData = feed
                self?.setData(data: feed.entry)
                completion()
        }, onError: { [weak self] (error) in
            if UserDefault.current.listData != nil {
                self?.setData(data: UserDefault.current.listData?.entry ?? [])
                completion()
            }
        }).disposed(by: appDelegate.disposeBag)
    }
    
    func loadListData(completion: @escaping () -> ()){
        var addCount = numberOfPagination
        let initialIndex = currentPage * numberOfPagination
        for (index,data) in data.enumerated() {
            if index >= initialIndex && addCount > 0{
                displayList.append(data)
                addCount -= 1
                getItemData(id: data.id) {
                    completion()
                }
            }
            
            if addCount == 0 {
                break
            }
            
        }
        currentPage += 1
//        completion()
    }
    
    func getFilterList(keyword: String, completion: @escaping () -> ()){
        let key = keyword.lowercased()
        if keyword.count > 0 {
            let filterList = self.data.filter { (listViewModel) -> Bool in
                return listViewModel.title.lowercased().contains(key) || listViewModel.category.lowercased().contains(key) || listViewModel.summary.lowercased().contains(key) ||
                    listViewModel.author.lowercased().contains(key)
            }
            
            self.displayList = filterList
        }else {
            self.displayList = self.data
        }
        completion()
    }
    
    func getItemData(id:Int, completion: @escaping () -> ()){
        let request = WebServices.RequestModule.AppListing.getItemData(id: id)
                            
        WebServices.requestModel(request: request)
            .subscribe(onNext: { [weak self] (response) in
                guard let data = response.Data else { return }
                guard let result = data.results.first else { return }
                self?.updateData(data: result, completion: {
                    completion()
                })
        }, onError: { (error) in
    
        }).disposed(by: appDelegate.disposeBag)
    }
}


struct ListItem {
    let id: Int
    var position: Int
    var icon: String
    var title: String
    var category: String
    var rating: Double
    var numOfAdvices: String
    var summary: String
    var author: String
    
    init(data: Listing) {
        self.id = Int(data.id?.attributes?.im_id ?? "-1") ?? -1
        self.position = 0
        self.icon = data.im_image?.first?.label ?? ""
        self.title = data.name?.label ?? ""
        self.category = data.category?.attributes?.label ?? ""
        self.rating = 0
        self.numOfAdvices = "(0)"
        self.summary = data.summary?.label ?? ""
        self.author = data.im_artist?.label ?? ""
    }
    
    func getRatingView() -> CosmosView  {
        let view = CosmosView()
        view.text = numOfAdvices
        view.rating = Double(rating)
        view.settings.fillMode = .precise
        view.settings.starSize = 12
        view.settings.starMargin = 2
        view.isUserInteractionEnabled = false
        return view
    }
}
