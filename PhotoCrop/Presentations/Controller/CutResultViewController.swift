//
//  CutResultViewController.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit


final class CutResultViewController: UIViewController {
    var scrollView = UIScrollView()
    var containerView = UIView()
    var imageView = UIImageView()
    
    
    var image: UIImage?
    var backButton = UIButton(type: .system)
    
    init(image: UIImage?) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insertUI()
        basicSetUI()
        anchorUI()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = .white
        imageView.image = image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func insertUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(imageView)
    }
    
    func basicSetUI() {
        scrollView.backgroundColor = .white
        containerView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.setTitle("뒤로", for: .normal)
        let bar = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = bar
    }
    
    func anchorUI() {
        guard let image = image else { return }
        print(image.size)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
            
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
        }
        
        imageView.snp.makeConstraints {
            $0.leading.trailing.top.equalTo(containerView)
            $0.width.equalTo(image.size.width/3)
            $0.height.equalTo(image.size.height/3)
        }
    }
}
