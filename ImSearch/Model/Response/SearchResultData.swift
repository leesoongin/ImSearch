//
//  SearchResultData.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/24.
//

import UIKit

struct SearchResultData: Codable {
    let meta: MetaData
    let documents: [Document]
}

struct MetaData: Codable{
    let total_count: Int  // 검색된 문서 수
    let pageable_count: Int  // total_count 중 노출 가능 문서 수
    let is_end: Bool  // 마지막 페이지 여부
}

struct Document: Codable{
    let collection: String // 분류
    let thumbnail_url: String
    let image_url: String
    let width: Int
    let height: Int
    let display_sitename: String // 출처
}

