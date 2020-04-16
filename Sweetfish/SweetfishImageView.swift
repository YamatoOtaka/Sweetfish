//
//  SweetfishImageView.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/15.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

public final class SweetfishImageView: UIImageView {
    private lazy var segmentationView = SegmentationView()
    private lazy var mlManager = CoreMLManager.init(type: .deepLabV3)
    private var predictCompletionHandler: ((Error?) -> Void)?
    private var colors: [Int32: UIColor] = [:]

    var mlModelType: CoreMLModelType = .deepLabV3 {
        didSet {
            self.mlManager = CoreMLManager.init(type: mlModelType)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func predict(completion: @escaping ((Error?) -> Void)) {
        self.predictCompletionHandler = completion
        guard let cgImage = image?.cgImage else {
            // TODO: Add Error.
            self.predictCompletionHandler?(nil)
            return
        }
        mlManager.predict(with: cgImage) {[weak self] mlMulutiArray, error in
        }
    }

    private func setupViews() {
    }
}

