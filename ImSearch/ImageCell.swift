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
//        TODO: 1. 메모리 캐시에 이미지가 존재하는지 확인, 존재한다면 이미지 로드
//        TODO: 2. 메모리 캐시에 이미지가 존재하지 않으므로 디스크 캐시에 존재하는지 확인, 존재한다면 이미지 로드
//        TODO: 3. 메모리, 디스크 캐시에 이미지가 존재하지 않는다면 메모리 and 디스크 캐시에 이미지를 저장하고 이미지 load
        if self.imageViewForCell.setCacheImageFromMemory(imageURL) == false {
            if self.imageViewForCell.setCacheImageFromDisk(imageURL) == false {
                self.imageViewForCell.setImageFromURL(imageURL)
            }
        }
        // 이미지 라이브러리 사용 - Kingfisher
//        guard let url = URL(string: imageURL) else { return }
//        imageViewForCell.kf.indicatorType = .activity
//        imageViewForCell.kf.setImage(with: url)
    }
    private func setup(){
        
    }
}

extension UIImageView {
    func setCacheImageFromMemory(_ url: String) -> Bool{
        guard let url = URL(string: url) else { return false}
        
        if let cacheImage = ImageCacheManager.shared.object(forKey: url.lastPathComponent as NSString){
            print("메모리 캐시에서 이미지 로드 ===== ")
            self.image = cacheImage
            // 메모리 캐시에 존재하면 true return 으로 함수 종료
            return true
        }
        return false  // 캐시에 이미지가 존재하지 않았다면 false return
    }
    
    //TODO: 1. 기본적으로 제공되는 cache 폴더 경로 불러오기
    //TODO: 2. 파일 이름으로 filePath의 path 설정
    //TODO: 3. 해당 path에 파일이 존재하지 않는다면 retrun false   /  존재한다면 캐시에서 이미지 불러오고 메모리에 캐싱, return true
    
    func setCacheImageFromDisk(_ url: String) -> Bool {
        if let url = URL(string: url){
            if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                var filePath = URL(fileURLWithPath: path)
                let fileManager = ImageCacheManager.fileManager
                
                filePath.appendPathComponent(url.lastPathComponent)
                
                if !fileManager.fileExists(atPath: filePath.path) {
                    return false
                } //if
                else{
                    // 존재한다면 캐시에서 이미지 불러오기
                    guard let imageData = try? Data(contentsOf: filePath) else {
                        print("disk cache image data nil")
                        return false
                    }
                    guard let image = UIImage(data: imageData) else { return false }
                    ImageCacheManager.shared.setObject(image, forKey: url.lastPathComponent as NSString) //메모리에 캐싱
                    
                    print("디스크 캐시에서 이미지 로드 ===== ")
                    self.image = image
                    return true
                }
            } //path
        } //url
        return false
    }
    
    func setImageFromURL(_ url: String){
        if let url = URL(string: url) {
            if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
                var filePath = URL(fileURLWithPath: path)
                let fileManager = ImageCacheManager.fileManager
                filePath.appendPathComponent(url.lastPathComponent)
                
                DispatchQueue.global(qos: .background).async {
                    URLSession.shared.dataTask(with: url){ (data, res, err) in
                        if let _ = err{
                            print("error 처리")
                            return
                        }
                        DispatchQueue.main.async {
                            if let data = data, let image = UIImage(data: data){
                                // 메모리 캐싱
                                ImageCacheManager.shared.setObject(image, forKey: url.lastPathComponent as NSString)
                                // 디스크 캐싱
                                fileManager.createFile(atPath: filePath.path,
                                                       contents: image.jpegData(compressionQuality: 0.4),
                                                       attributes: nil)
                                print("URL 에서 이미지 로드 ===== ")
                                self.image = image
                            }
                        }
                    }.resume() //session
                } //dispatch
            } //path
        } //url
    }
}



//extension UIImage{
//    func resize(newWidth: CGFloat) -> UIImage {
//        let scale = newWidth / self.size.width
//        let newHeight = self.size.height * scale
//        let size = CGSize(width: newWidth, height: newHeight)
//        let render = UIGraphicsImageRenderer(size: size)
//        let renderImage = render.image { context in self.draw(in: CGRect(origin: .zero, size: size)) }
////        print("화면 배율: \(UIScreen.main.scale)")// 배수
////        print("origin: \(self), resize: \(renderImage)")
//
//        return renderImage
//    }
//}
