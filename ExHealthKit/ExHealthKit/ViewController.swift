//
//  ViewController.swift
//  ExHealthKit
//
//  Created by sonjuhyeong on 2023/01/19.
//

import UIKit
import SnapKit

import RxSwift

class ViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let heathKitView = HeathKitView()
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = heathKitView
        bind()
    }
    
    private func bind() {
        viewModel.input.onLoad.onNext(())
        
        viewModel.output.stepCount
            .bind(to: heathKitView.todayStepsLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.errorMessage
            .bind { [weak self] (message) in
                self?.alert(message: message)
            }.disposed(by: disposeBag)
    }
   
}

extension UIViewController {
    func alert(title : String = "알림", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
