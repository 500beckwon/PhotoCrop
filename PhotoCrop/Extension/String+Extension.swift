//
//  String+Extension.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/02.
//

import Foundation

extension String {
    func localTitleConfirm() -> String {
        let text: String
        switch self {
        case "Selfies":
           text = "셀카"
        case "Favorites":
            text = "즐겨찾는 항목"
        case "Recents":
            text = "최근 항목"
        case "Screenshots":
            text = "스크린샷"
        case "Panoramas":
            text = "파노라마"
        default:
            text = self
        }
        return text
    }
}
