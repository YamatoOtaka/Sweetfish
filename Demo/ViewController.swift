//
//  ViewController.swift
//  Demo
//
//  Created by 大高倭 on 2020/04/16.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit
import Sweetfish

class ViewController: UIViewController {

    let sweetfishImageView = SweetfishImageView()

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 23
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.addSubview(sweetfishImageView)
        sweetfishImageView.setConstraintsToFill()
        setupSweetfish()
    }

    @IBAction func buttonTap(_ sender: Any) {
        if sweetfishImageView.isMaskImage {
            sweetfishImageView.reset()
            button.setTitle("Predicr", for: .normal)
        } else {
            sweetfishImageView.predict {[weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    self.button.setTitle("Reset", for: .normal)
                }
            }
        }
    }

    func setupSweetfish() {
        sweetfishImageView.mlModelType = .deepLabV3
        sweetfishImageView.contentMode = .scaleAspectFit
        sweetfishImageView.image = UIImage(named: "fish")
    }
}

extension UIView {
    func setConstraintsToFill() {
        guard let superView = self.superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }
}
