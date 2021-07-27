//
//  KakaoSearchAPIManager.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/24.
//

import UIKit
import Alamofire

protocol KakaoAPIDataSource {
    var REQUEST_URL: String { get }
    var HTTP_HEADERS: HTTPHeaders { get }
}

class KakaoSearchAPIManager: KakaoAPIDataSource {
    let REQUEST_URL: String = "https://dapi.kakao.com/v2/search/image"
    let HTTP_HEADERS: HTTPHeaders = ["Authorization":"KakaoAK 0caaa5a18f9994189a279bb72e41d19e"]
    
    static let shared = KakaoSearchAPIManager()
    
    func requestSearchImage(parameter: SearchParam, completion: @escaping ((SearchResultData) -> (Void))){
        AF.request(REQUEST_URL, method: .get, parameters: parameter.toDictionary , headers: HTTP_HEADERS).validate(statusCode: 200..<300).responseJSON { response in
            switch response.result {
            case .success:
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: response.value!, options: .prettyPrinted)
                    let json = try JSONDecoder().decode(SearchResultData.self, from: jsonData)
                    completion(json)
                }catch let error {
                    print("parsing error -> \(error.localizedDescription)")
                }
            case .failure:
                print("fail , statusCode --> \(response.result)")
            }
        }
    }
}
