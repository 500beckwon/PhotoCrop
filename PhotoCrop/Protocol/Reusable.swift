//
//  Reusable.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }

    static var nib: UINib? {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}
