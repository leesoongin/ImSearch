//
//  SearchParam.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/24.
//

import UIKit


struct SearchParam {
    var query: String // Required
    var sort: String
    var page: Int
    var size: Int
    
    init(query: String, sort: String, page: Int, size: Int) {
        self.query = query
        self.sort = sort
        self.page = page
        self.size = size
    }
    //MARK: - mutating func
    mutating func modifyQuery(query: String){
        self.query = query
    }
    mutating func modifySort(sort: String){
        self.sort = sort
    }
    mutating func updatePage(page: Int){
        self.page = page + 1
    }
    mutating func initialPage(){
        self.page = 1
    }
    
    //MARK: - getter
    func getQuery() -> String {
        return self.query
    }
    func getSort() -> String{
        return self.sort
    }
    func getPage() -> Int{
        return self.page
    }
    func getSize() -> Int{
        return self.size
    }
    
    enum paramName: String {
        case query
        case sort
        case page
        case size
    }
    
    
    var toDictionary: [String: Any] {
        let dict: [String: Any] = [
            paramName.query.rawValue : self.query,
            paramName.sort.rawValue : self.sort,
            paramName.page.rawValue : self.page,
            paramName.size.rawValue : self.size
        ]
        
        return dict
    }
}
