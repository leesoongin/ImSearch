//
//  ImageCell.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/24.
//

import UIKit
import Kingfisher

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewForCell: UIImageView!

    override init(frame : CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(imageURL: String,newWidth: CGFloat){
        let url = URL(string: imageURL)

//        do{
//            if let url = url {
//                let data = try Data(contentsOf: url)
//                imageViewForCell.image = UIImage(data: data)?.resize(newWidth: newWidth)
//            }
//        }catch{
//            print("data fetch error")
//        }
        imageViewForCell.kf.setImage(with: url)
        
    }
    private func setup(){
        
    }
}

extension UIImage{
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in self.draw(in: CGRect(origin: .zero, size: size)) }
//        print("화면 배율: \(UIScreen.main.scale)")// 배수
//        print("origin: \(self), resize: \(renderImage)")

        return renderImage
    }
}
