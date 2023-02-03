//
//  PhotoCropTypeButton.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/31.
//

import UIKit
import RxCocoa
import RxSwift


/// 사진 편집 화면에서 정,가,세를 고를 수 있는 단일 버튼을 모은 3단 버튼

final class PhotoCropTypeButton: UIView {
    private let stackView = UIStackView()
    private var squareButton = CropButton()
    private var horizontalSquareButton = CropButton(.horizontal)
    private var verticalSquareButton = CropButton(.vertical)
    
    private let disposeBag = DisposeBag()
    
    let didSelectedCrop = BehaviorRelay<PhotoCropType>(value: .square)
    
    init() {
        super.init(frame: .zero)
        insertUI()
        basicSetUI()
        anchorUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindUI() {
        let cropButtonList = [
            horizontalSquareButton,
            verticalSquareButton,
            squareButton,
        ]
        
        cropButtonList
            .forEach {
                $0.rx.photoCropTap
                    .throttle(.milliseconds(250), scheduler: MainScheduler.instance)
                    .bind(to: didSelectedCrop)
                    .disposed(by: disposeBag)
            }
       
        didSelectedCrop
            .subscribe(onNext: { type in
                cropButtonList.forEach { button in
                    button.isSelected = type == button.photoCropType
                }
            }).disposed(by: disposeBag)
    }
}

extension PhotoCropTypeButton {
    func insertUI() {
        addSubview(stackView)
        
        [
            squareButton,
            horizontalSquareButton,
            verticalSquareButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    func basicSetUI() {
        clipsToBounds = true
        backgroundColor = .clear
        layer.cornerRadius = 18
        
        stackView.clipsToBounds = true
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.alpha = 1
        stackView.spacing = 0
    }
    
    func anchorUI() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
