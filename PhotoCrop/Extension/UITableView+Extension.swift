//
//  UITableView+Extension.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit

extension UITableView {
    func registerCell<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
    
    func initCellForItem<T: UITableViewCell>(indexPath: IndexPath) -> T {
        return self.cellForRow(at: indexPath) as! T
    }
    
    
}

extension UITableViewCell: Reusable { }
