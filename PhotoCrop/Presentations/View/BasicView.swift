//
//  BasicView.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/02.
//

import UIKit

class BasicView: UIView, BasicViewDrawRule {
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        insertUI()
        basicSetUI()
        anchorUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertUI() {
        
    }
    
    func basicSetUI() {
        
    }
    
    func anchorUI() {
        
    }
}
