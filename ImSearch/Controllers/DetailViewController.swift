//
//  DetailViewController.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/25.
//

import UIKit
import Kingfisher

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
    
    func loadDetailImage(){
        if let imageURL = self.detailImageURL {
            detailImageView.kf.setImage(with: URL(string: imageURL))
        }
    }
    func setNavigationTitle(){
        if let title = self.navigationTitle {
            self.navigationItem.title = title
        }
    }
}

extension DetailViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.detailImageView
    }
}
