//
//  SearchResultViewModel.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/24.
//

import UIKit

class SearchResultViewModel {
    static let shared = SearchResultViewModel()
    
    private var searchResultData: SearchResultData?
    private var metaData: MetaData?
    private var documents: [Document] = [Document]()
    // 하나의 request parameter를 이용해서 값을 바꿔주며 api호출하는 식으로 해보자 일단
    private var searchParam: SearchParam = SearchParam(query: "", sort: "", page: 1, size: 80)
    private let scopeTitle: ScopeTitle = ScopeTitle()
    private let navigationTitle: String = "이미지 검색"
    //MARK: - getter
    func getData() -> SearchResultData?{
        return self.searchResultData
    }
    func getMetaData() -> MetaData?{
        return self.metaData
    }
    func getDocuments() -> [Document]{
        return self.documents
    }
    func getSearchParam() -> SearchParam{
        return self.searchParam
    }
    func getScopeTitleKey() -> [String]{
        return scopeTitle.getScopeTitleKeys()
    }
    private func getScopeTitleValues() -> [String]{
        return scopeTitle.getScopeTitleValues()
    }
    func getNavigationTitle() -> String {
        return self.navigationTitle
    }
    
    //MARK: - searchParameter 새로고침
    func modifySearchParamQuery(query: String){
        self.searchParam.modifyQuery(query: query)
    }
    func modifySearchParamSort(sort: Int){
        // 0 -> 정확도 순(default)    /   1 -> 최신순
        let values: [String] = getScopeTitleValues()
        
        switch sort {
        case 0:
            self.searchParam.modifySort(sort: values[sort])
        case 1:
            self.searchParam.modifySort(sort: values[sort])
        default:
            print("잘못된 입력입니다. ㅋㅋㅅㅋ")
        }
    }
    func updateSearchParamPage(){
        self.searchParam.updatePage(page: self.searchParam.getPage())
    }
    func initialSearchParamPage(){
        self.searchParam.initialPage()
    }
    //MARK: - Initializing SearchResultData, MetaData, Documents, RequestParmeter
    func modifySearchResultData(searchResultData: SearchResultData?){
        // data 새로고침
        initialSearchParamPage()
        if let data = searchResultData {
            self.searchResultData = data
            // metaData, Document, request parameter 초기화
            modifyMetaData()
            modifyDocuments()
            
        }
    }
    private func modifyMetaData(){
        if let data = self.searchResultData{
            self.metaData = data.meta
        }
    }
    private func modifyDocuments(){
        if let data = self.searchResultData{
            self.documents = data.documents
        }
    }
    
    //MARK: - 페이징시 원소 append
    func addDocuments(results: [Document]){
        self.documents.append(contentsOf: results)
    }
    
    func chageSearchParamSort(sort: Int){
        self.modifySearchParamSort(sort: sort) // sort 바꾸고
        self.initialSearchParamPage() // page 초기화
    }
    
}
