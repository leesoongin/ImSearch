//
//  ViewController.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/24.
//

import UIKit

protocol SearchViewDelegate {
    func isValidQuery(query: String) -> Bool // 적합한 검색어인지 판별
    func beginPaging() // Paging
    func setFalseToSearchControllerIsActive() // SearchController의 isActive -> false
    func scrollToTop() // 현재 보고있는 스크롤을 맨 위로
}

protocol SearchViewDataSource {
    func addSearchControllerInNavigationBar() // navigation bar에 searchController 넣기
    func lastPageAlert() // 마지막 페이지 alert
}

class ViewController: UIViewController {
    //MARK: - IBOulet
    @IBOutlet var searchController: UISearchController!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    //MARK: - Manager, ViewModel
    private let manager: KakaoSearchAPIManager = KakaoSearchAPIManager.shared
    private let viewModel: SearchResultViewModel = SearchResultViewModel.shared
    
    //MARK: - view LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSearchControllerInNavigationBar()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailView"{
            guard let nextVC = segue.destination as? DetailViewController else { return }
            guard let cell: UICollectionViewCell = sender as? UICollectionViewCell else { return }
            guard let index: IndexPath = self.collectionView.indexPath(for: cell) else { return }
            
            nextVC.detailImageURL = self.viewModel.getDocuments()[index.row].image_url
            nextVC.navigationTitle = self.viewModel.getSearchParam().getQuery()
            nextVC.modalPresentationStyle = .fullScreen
        }
    }
}

//MARK: - SearchView Delegate
extension ViewController: SearchViewDelegate{
    func isValidQuery(query: String) -> Bool {
        let queryRegEx = "^[가-힣a-zA-Z0-9 ]{1,15}$"
        let test = NSPredicate(format: "SELF MATCHES %@", queryRegEx)
        return test.evaluate(with: query)
    }
    func beginPaging(){
        guard let isEnd = self.viewModel.getMetaData()?.is_end else { return }
        
        if !isEnd {
            self.viewModel.updateSearchParamPage()
            self.manager.requestSearchImage(parameter: self.viewModel.getSearchParam()) { response in
                self.viewModel.addDocuments(results: response.documents)
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }//closure
        }//if
        else{
            self.lastPageAlert()
        }
    }
    func scrollToTop(){
        self.collectionView.scrollToItem(at: IndexPath(index: 0), at: .top, animated: true)
    }
    func setFalseToSearchControllerIsActive(){
        self.searchController.isActive = false
    }
}

//MARK: - SearchView DataSource
extension ViewController: SearchViewDataSource{
    func addSearchControllerInNavigationBar(){
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self // 입력란 업데이트마다 콜백 메서드
        searchController.obscuresBackgroundDuringPresentation = false // 뒤에 안이쁘니까 지우자 ㅋㅋ
        searchController.searchBar.scopeButtonTitles = self.viewModel.getScopeTitleKey()
        searchController.searchBar.placeholder = "검색"
//        searchController.searchBar.showsScopeBar = true // scopebar 항상 나오기
//        searchController.hidesNavigationBarDuringPresentation = false // searchbar쓸때 네비게이션 타이틀 안숨기기
        
        self.navigationItem.searchController = searchController
        self.navigationItem.title = self.viewModel.getNavigationTitle()
        self.navigationItem.hidesSearchBarWhenScrolling = true //스크롤할때 searchbar 안숨기기 -> false
    }
    func lastPageAlert(){
        let alert = UIAlertController(title: "알림", message: "마지막 페이지입니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "넹", style: .default) { (ok) in
           print("그래 그래~")
        }
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
}
//MARK: - extension UISearcBarDelegate
extension ViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.viewModel.chageSearchParamSort(sort: selectedScope)
        self.manager.requestSearchImage(parameter: self.viewModel.getSearchParam()) { response in
            self.viewModel.modifySearchResultData(searchResultData: response)
            self.collectionView.reloadData()
            self.scrollToTop()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchController.searchBar.text else { return }
        
        if text != "" && self.isValidQuery(query: text){
            // 검색어, page parameter 초기화
            self.viewModel.modifySearchParamQuery(query: text)
            self.viewModel.initialSearchParamPage()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
                self.manager.requestSearchImage(parameter: self.viewModel.getSearchParam()){ response in // response -> resultData
                    self.viewModel.modifySearchResultData(searchResultData: response)
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }//request
            } // dispatchQueue
        } //if
    }//delegate
}

//MARK: - UICollectionview DataSource
extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getDocuments().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let margin: CGFloat = 2
        let newWidth: CGFloat = (self.view.frame.width - (margin * 2)) / 3
        
        cell.configure(imageURL: self.viewModel.getDocuments()[indexPath.row].thumbnail_url,newWidth: newWidth)
        
        return cell
    }  
}

//MARK: - UICollectionView Delegate
extension ViewController: UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("나오냐??")
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        setFalseToSearchControllerIsActive()
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // 스크롤이  collectionView Offset의 끝에 가게 되면 다음 페이지를 호출
        if offsetY > (contentHeight - height) {
            if self.viewModel.getDocuments().count != 0{
                beginPaging()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setFalseToSearchControllerIsActive()
    }
}

//MARK: - UICollectionView Delegate FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let margin: CGFloat = 2
        let width: CGFloat = (self.view.frame.width - (margin * 2)) / 3
        let height: CGFloat = width
        
        return CGSize(width: width, height: height)
    }
}

//MARK: - extension UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
//        if let text = searchController.searchBar.text{
//            if text != "" && self.isValidQuery(query: text){
//                self.viewModel.modifySearchParamQuery(query: text)
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
//                    self.manager.requestSearchImage(parameter: self.viewModel.getSearchParam()){ response in // response -> resultData
//                        self.viewModel.modifySearchResultData(searchResultData: response)
//
//                        DispatchQueue.main.async {
//                            self.collectionView.reloadData()
//                        } //inner dispatchQueue
//                    }//request
//
////                    self.scrollToTop()
//                } // dispatchQueue
//            } //inner if
//        } //if
    }//func
}
