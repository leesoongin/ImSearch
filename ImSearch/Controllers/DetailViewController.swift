//
//  DetailViewController.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/25.
//

import UIKit
import Kingfisher

//MARK: - DetailView Controller Delegate
protocol DetailViewControllerDelegate {
    func loadDetailImage() // detail image load
    func setNavigationTitle() // navigation title 텍스트 설정
}

//MARK: - Controller
class DetailViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    var detailImageURL: String?
    var navigationTitle: String?
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDetailImage()
        setNavigationTitle()
    }
    
    @IBAction func saveImageToAlbum(_ sender: Any) {
        // 이미지를 사진첩에 저장
        //TODO: 저장할건지 여부 물어보자
        guard let image = self.detailImageView.image else {
            print("이미지를 로드할 수 없뜸니다 ,,,")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(setImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func setImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
           //사진 저장 한후
           if let error = error {
               // we got back an error!
            print("에러처리 아몰랑 ~ \(error.localizedDescription)")
           } else {
                // save
            completeAlert()
           }
    }
    func completeAlert(){
        let alert = UIAlertController(title: "알림", message: "저장이 완료되었습니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "넹", style: .default) { (ok) in
           print("그래 그래~")
        }
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
}
//MARK: - DetailView Delegate
extension DetailViewController: DetailViewControllerDelegate {
    func loadDetailImage(){
        if let imageURL = self.detailImageURL {
            detailImageView.kf.indicatorType = .activity
            detailImageView.kf.setImage(with: URL(string: imageURL))
        }
    }
    func setNavigationTitle(){
        if let title = self.navigationTitle {
            self.navigationItem.title = title
        }
    }
}
//MARK: - ScrollView Delegate
extension DetailViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
}
