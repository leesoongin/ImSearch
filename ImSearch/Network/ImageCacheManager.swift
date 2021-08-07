//
//  ImageCacheManager.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/08/02.
//

import UIKit

class ImageCacheManager {
    static let shared = NSCache<NSString,UIImage>() // Memory cache 위함
    static let fileManager = FileManager() // disk cache 위함
    
    private init() { }
}
