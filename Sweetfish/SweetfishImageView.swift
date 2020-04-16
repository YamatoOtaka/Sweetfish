//
//  SweetfishImageView.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/15.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

public final class SweetfishImageView: UIImageView {
    private lazy var mlManager = CoreMLManager.init(type: .deepLabV3)
    private var predictCompletionHandler: ((Error?) -> Void)?

    public var mlModelType: CoreMLModelType = .deepLabV3 {
        didSet {
            self.mlManager = CoreMLManager.init(type: mlModelType)
        }
    }

    public var isMaskImage: Bool {
        return subviews.count != 0
    }

    public func predict(completion: @escaping ((Error?) -> Void)) {
        predictCompletionHandler = completion
        guard let cgImage = image?.cgImage else {
            // TODO: Add Error.
            self.predictCompletionHandler?(nil)
            return
        }
        mlManager.predict(with: cgImage) {[weak self] mlMulutiArray, error in
            self?.configureSegmentation(mlMulutiArray: mlMulutiArray)
            DispatchQueue.main.async {[weak self] in
                self?.predictCompletionHandler?(error)
            }
        }
    }

    public func reset() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }

    private func configureSegmentation(mlMulutiArray: SegmentationResultMLMultiArray?) {
        let segmentationView = SegmentationView()
        addSubview(segmentationView)
        segmentationView.backgroundColor = .clear
        segmentationView.frame = self.imageFrame
        segmentationView.segmentationmap = mlMulutiArray
    }
}

