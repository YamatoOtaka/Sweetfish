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
    var originalImage: UIImage?

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var resetButton: UIButton! {
        didSet {
            resetButton.layer.cornerRadius = 23
        }
    }
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 23
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        baseView.addSubview(sweetfishImageView)
        sweetfishImageView.setConstraintsToFill()

        setupSweetfish()
    }

    @IBAction func buttonTap(_ sender: Any) {
        updateIndicatorState(shouldShow: true)
        button.isEnabled = false
        resetButton.isEnabled = false
        sweetfishImageView.predict(clippingMethod: .object(objectType: .fish))
    }

    @IBAction func resetButtonTap(_ sender: Any) {
        sweetfishImageView.image = originalImage
    }

    func setupSweetfish() {
        sweetfishImageView.mlModelType = .deepLabV3
        sweetfishImageView.contentMode = .scaleAspectFit
        sweetfishImageView.image = UIImage(named: "fish")
        sweetfishImageView.delegate = self
    }

    func updateIndicatorState(shouldShow: Bool) {
        if shouldShow {
            indicator.isHidden = false
            indicator.startAnimating()
        } else {
            indicator.isHidden = true
            indicator.stopAnimating()
        }
    }
}
extension ViewController: SweetfishImageViewDelegate {
    func sweetfishImageView(clipDidFinish result: Result) {
        self.updateIndicatorState(shouldShow: false)
        self.button.isEnabled = true
        self.resetButton.isEnabled = true

        switch result {
        case .success(let originalImage, let clippingImage):
            self.originalImage = originalImage
        case .failure(let error):
            print(error.localizedDescription)
        }
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
