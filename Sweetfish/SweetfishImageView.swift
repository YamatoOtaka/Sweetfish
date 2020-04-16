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

    var mlModelType: CoreMLModelType = .deepLabV3 {
        didSet {
            self.mlManager = CoreMLManager.init(type: mlModelType)
        }
    }

    override public var image: UIImage? {
        didSet {
            segmentationView.frame = self.imageFrame
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
        predictCompletionHandler = completion
        guard let cgImage = image?.cgImage else {
            // TODO: Add Error.
            self.predictCompletionHandler?(nil)
            return
        }
        segmentationView.frame = self.imageFrame
        mlManager.predict(with: cgImage) {[weak self] mlMulutiArray, error in
            self?.segmentationView.segmentationmap = mlMulutiArray
            DispatchQueue.main.async {[weak self] in
                self?.predictCompletionHandler?(error)
            }
        }
    }

    private func setupViews() {
        addSubview(segmentationView)
        segmentationView.backgroundColor = .clear
    }
}

