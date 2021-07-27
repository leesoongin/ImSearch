//
//  ScopeTitle.swift
//  ImSearch
//
//  Created by 이숭인 on 2021/07/27.
//

import UIKit

struct ScopeTitle {
    let keys: [String] = [
                        "정확도순",
                        "최신순"
                        ]
    let values: [String] = [
                        "accuracy",
                        "recency"
                        ]
    
    //MARK: - getter
    func getScopeTitleKeys() -> [String] {
        return keys
    }
    func getScopeTitleValues() -> [String] {
        return values
    }
}
