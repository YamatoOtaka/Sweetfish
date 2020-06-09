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

public protocol SweetfishImageViewDelegate: class {
    func sweetfishImageView(clipDidFinish result: Result)
}

public final class SweetfishImageView: UIImageView {
    private lazy var mlManager = CoreMLManager.init(type: .deepLabV3)
    private var currentSegmentationView: SegmentationView?

    public weak var delegate: SweetfishImageViewDelegate?
    public var mlModelType: CoreMLModelType = .deepLabV3 {
        didSet {
            self.mlManager = CoreMLManager.init(type: mlModelType)
        }
    }

    public func clipping(clippingMethod: ClippingMethod) {
        cancelSelectClipping()

        guard let image = image, let cgImage = image.cgImage else {
            delegate?.sweetfishImageView(clipDidFinish: .failure(error: SweetfishError.cgImageNotFound))
            return
        }
        mlManager.predict(with: cgImage) {[weak self] result in
            switch result {
            case .success(let mlMultiArray):
                self?.configureSegmentation(clippingMethod: clippingMethod, image: image, mlMultiArray: mlMultiArray) { result in
                    self?.delegate?.sweetfishImageView(clipDidFinish: result)
                }
            case .failure(let error):
                self?.delegate?.sweetfishImageView(clipDidFinish: .failure(error: error))
            }
        }
    }

    public func cancelSelectClipping() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }

    private func configureSegmentation(clippingMethod: ClippingMethod, image: UIImage, mlMultiArray: SegmentationResultMLMultiArray?, completionHandler: @escaping ((Result) -> Void)) {
        DispatchQueue.main.async {
            let segmentationView = SegmentationView()
            self.currentSegmentationView = segmentationView
            self.addSubview(segmentationView)
            segmentationView.backgroundColor = .clear
            segmentationView.frame = self.imageFrame
            segmentationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.segmentationViewDidTap(_:))))
            segmentationView.updateSegmentationMap(segmentationMap: mlMultiArray, clippingMethod: clippingMethod) {[weak self] segmentationResult in
                switch segmentationResult {
                case .success(let maskImage):
                    switch clippingMethod {
                    case .selectTouch:
                        self?.isUserInteractionEnabled = true
                        completionHandler(.success(originalImage: image, clippingImage: maskImage))
                    default:
                        if let maskedImage = image.masking(maskImage: maskImage) {
                            self?.subviews.forEach { $0.removeFromSuperview() }
                            self?.image = maskedImage
                            completionHandler(.success(originalImage: image, clippingImage: maskedImage))
                        } else {
                            completionHandler(.failure(error: SweetfishError.maskingImageRetrieved))
                        }
                    }
                case .failure(let error):
                    completionHandler(.failure(error: error))
                }
            }
        }
    }

    @objc private func segmentationViewDidTap(_ gesture: UITapGestureRecognizer) {
        guard let segmentationView = currentSegmentationView, let segmentationMap = segmentationView.segmentationmap else {
            self.delegate?.sweetfishImageView(clipDidFinish: .failure(error: SweetfishError.unknown))
            return
        }
        let location = gesture.location(in: currentSegmentationView)
        // Fit touch point and segmentation area.
        let displayImageSize = self.imageFrame.size
        let positionX = Int(roundf(Float(location.x)))*Int(roundf(Float(segmentationMap.segmentationmapWidthSize / Int(displayImageSize.width))))
        let positionY = Int(roundf(Float(location.y)))*Int(roundf(Float(segmentationMap.segmentationmapHeightSize / Int(displayImageSize.height))))
        let value = segmentationView.createValueWithPoint(x: positionX, y: positionY)
        segmentationView.updateClippingMethod(clippingMethod: .selectValue(value: value), completionHandler: {[weak self] result in
            switch result {
            case .success(let maskImage):
                if let image = self?.image, let maskedImage = image.masking(maskImage: maskImage) {
                    self?.subviews.forEach { $0.removeFromSuperview() }
                    self?.image = maskedImage
                    self?.delegate?.sweetfishImageView(clipDidFinish: .success(originalImage: image, clippingImage: maskedImage))
                } else {
                    self?.delegate?.sweetfishImageView(clipDidFinish: .failure(error: SweetfishError.maskingImageRetrieved))
                }
            case .failure(let error):
                self?.delegate?.sweetfishImageView(clipDidFinish: .failure(error: error))
            }
        })
    }
}
