//
//  SweetfishImageView.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/15.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

public enum Result {
    case success(originalImage: UIImage, clippingImage: UIImage)
    case failure(error: Error)
}

public final class SweetfishImageView: UIImageView {
    private lazy var mlManager = CoreMLManager.init(type: .deepLabV3)
    private var predictCompletionHandler: ((Result) -> Void)?

    public var mlModelType: CoreMLModelType = .deepLabV3 {
        didSet {
            self.mlManager = CoreMLManager.init(type: mlModelType)
        }
    }

    public func predict(objectType: ObjectType, completion: @escaping ((Result) -> Void)) {
        predictCompletionHandler = completion
        guard let image = image, let cgImage = image.cgImage else {
            predictCompletionHandler?(.failure(error: SweetfishError.cgImageNotFound))
            return
        }
        mlManager.predict(with: cgImage) {[weak self] result in
            switch result {
            case .success(let mlMultiArray):
                self?.configureSegmentation(objectType: objectType, image: image, mlMultiArray: mlMultiArray) { result in
                    self?.predictCompletionHandler?(result)
                }
            case .failure(let error):
                self?.predictCompletionHandler?(.failure(error: error))
            }
        }
    }

    private func configureSegmentation(objectType: ObjectType, image: UIImage, mlMultiArray: SegmentationResultMLMultiArray?, completionHandler: @escaping ((Result) -> Void)) {
        DispatchQueue.main.async {
            let segmentationView = SegmentationView()
            self.addSubview(segmentationView)
            segmentationView.backgroundColor = .clear
            segmentationView.frame = self.imageFrame
            segmentationView.updateSegmentationMap(segmentationMap: mlMultiArray, objectType: objectType) {[weak self] segmentationResult in
                switch segmentationResult {
                case .success(let maskImage):
                    if let maskedImage = image.masking(maskImage: maskImage) {
                        self?.subviews.forEach { $0.removeFromSuperview() }
                        self?.image = maskedImage
                        completionHandler(.success(originalImage: image, clippingImage: maskedImage))
                    } else {
                        completionHandler(.failure(error: SweetfishError.maskingImageRetrieved))
                    }
                case .failure(let error):
                    completionHandler(.failure(error: error))
                }
            }
        }
    }
}
