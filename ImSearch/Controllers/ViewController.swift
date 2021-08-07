//
//  ViewController.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/24.
//

import UIKit
import RxSwift
import Combine

protocol SearchViewDelegate {
    func beginPaging() // Paging
    func resignFirstResponderFromSearchController() // SearchController의 isActive -> false
    func addSearchControllerObserver() // searchController에 observer add
    func requestSearchTermToAPI(searchTerm: String) // 검색어 api 요청
    func scrollToTop() // 현재 보고있는 스크롤을 맨 위로
}

protocol SearchViewDataSource {
    func setNavigationItem() // navigation item setting
    func setNoSearchImage() // 검색 결과가 없다면 나올 이미지
    func lastPageAlert() // 마지막 페이지 alert
}

class ViewController: UIViewController {
    //MARK: - IBOulet
    @IBOutlet weak var noSearchView: UIView!
    @IBOutlet weak var noSearchLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    private lazy var searchController : UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false // 뒤에 안이쁘니까 지우자 ㅋㅋ
        searchController.searchBar.scopeButtonTitles = self.viewModel.getScopeTitleKey()
        searchController.searchBar.placeholder = "검색"
        //        searchController.searchBar.showsScopeBar = true // scopebar 항상 나오기
        //        searchController.hidesNavigationBarDuringPresentation = false // searchbar쓸때 네비게이션 타이틀 안숨기기
        return searchController
    }()
    var mySubscription = Set<AnyCancellable>()
    
    //MARK: - Manager, ViewModel
    private let manager: KakaoSearchAPIManager = KakaoSearchAPIManager.shared
    private let viewModel: SearchResultViewModel = SearchResultViewModel.shared
    
    //MARK: - view LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItem()
        setNoSearchImage()
        addSearchControllerObserver()
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
    @IBAction func noSearchViewTabAction(_ sender: Any) {
        self.resignFirstResponderFromSearchController()
    }
    
}

//MARK: - SearchView Delegate
extension ViewController: SearchViewDelegate{
    func addSearchControllerObserver(){
        self.searchController.searchBar.searchTextField
            .myDebounceSearchPublisher
            .sink { receivedValue in
                self.requestSearchTermToAPI(searchTerm: receivedValue)
            }
            .store(in: &mySubscription)
    }
    func requestSearchTermToAPI(searchTerm: String) {
        self.scrollToTop()

        self.viewModel.modifySearchParamQuery(query: searchTerm)
        self.viewModel.initialSearchParamPage()
        self.manager.requestSearchImage(parameter: self.viewModel.getSearchParam()){ response in // response -> resultData
            self.viewModel.modifySearchResultData(searchResultData: response)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.setNoSearchImage()
            }
        }//request
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
    func resignFirstResponderFromSearchController(){
        self.searchController.searchBar.resignFirstResponder()
    }
}

//MARK: - SearchView DataSource
extension ViewController: SearchViewDataSource{
    func setNavigationItem(){
        self.navigationItem.searchController = searchController
        self.navigationItem.title = self.viewModel.getNavigationTitle()
        self.navigationItem.hidesSearchBarWhenScrolling = true //스크롤할때 searchbar 안숨기기 -> false
    }
    func setNoSearchImage() {
        if self.viewModel.getDocuments().count == 0{
            self.noSearchLabel.text = "검색 결과가 존재하지 않습니다."
        }else{
            self.noSearchLabel.text = ""
        }
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
            self.setNoSearchImage()
            self.collectionView.reloadData()
            self.scrollToTop()
        }
    }
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
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        resignFirstResponderFromSearchController()
        
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
        resignFirstResponderFromSearchController()
    }
}

//MARK: - UICollectionView Delegate FlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let margin: CGFloat = 2
        let width: CGFloat = (self.view.frame.width - (margin * 2)) / 3
        let height: CGFloat = width
        
        print("view width -----> \(self.view.frame.width) , cell width ----> \(width)")
        
        return CGSize(width: width, height: height)
    }
}
extension UISearchTextField {
    var myDebounceSearchPublisher : AnyPublisher<String,Never>{
        NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: self)
            // 노티피케이션 센터에서 UISearchTextField 가져옴
            .compactMap { $0.object as? UISearchTextField }
            //UISearchTextField 에서 text가져오기
            .map{ $0.text ?? "" }
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .filter{ $0.count > 0 }
            .print()
            .eraseToAnyPublisher()
    }
}

