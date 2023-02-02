//
//  File.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit
import RxCocoa
import RxSwift

protocol PhotoStyleEditViewDelegate: AnyObject {
    var selectedIndex: Int { get set}
}

final class PhotoStyleEditView: UIView {
    weak var delegate: PhotoStyleEditViewDelegate?
    
    private let stackView = UIStackView()
    private let containerView = UIView()
    
    let cropType = PhotoCropType.allCases
    
    var selectedIndex: Int = 0 {
        didSet {
            delegate?.selectedIndex = selectedIndex
        }
    }
    
    let selectedCrop = PublishRelay<PhotoCropType>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        alpha = 1.0
        backgroundColor = .clear
        clipsToBounds = true
        
        insertUI()
        basicSetUI()
        anchorUI()
        arrange()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 18
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButtonSelected(_ selectedIndex: Int) {
        stackView.arrangedSubviews.forEach { button in
            if let button = button as? UIButton {
                if button.tag != selectedIndex {
                    button.alpha = 0.5
                    button.isSelected = false
                } else {
                    button.alpha = 1.0
                    button.isSelected = true
                }
            }
        }
    }
}

private extension PhotoStyleEditView {
    func insertUI() {
        addSubview(containerView)
        containerView.addSubview(stackView)
    }
    
    func basicSetUI() {
        containerView.backgroundColor = .black
        containerView.alpha = 0.5
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 4
        stackView.alpha = 1
        stackView.spacing = 1
    }
    
    func anchorUI() {
        containerView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self)
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalTo(containerView)
        }
    }
    
    func arrange() {
        
        cropType.forEach {
            let button = UIButton(type: .system)
            button.setImage($0.image, for: .normal)
            button.backgroundColor = .clear
            button.clipsToBounds = true
            button.tintColor = .clear
            button.addTarget(self, action: #selector(didSelectedButton), for: .touchUpInside)
            button.tag = $0.rawValue
            stackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.height.width.equalTo(30)
            }
        }
    }
    
    @objc func didSelectedButton(_ sender: UIButton) {
        sender.isSelected = true
        sender.alpha = sender.isSelected ? 1.0: 0.5
        stackView.arrangedSubviews.forEach { button in
            if let button = button as? UIButton {
                if button.tag != sender.tag {
                    button.alpha = 0.5
                    button.isSelected = false
                }
            }
        }
        selectedIndex = sender.tag
    }
}
