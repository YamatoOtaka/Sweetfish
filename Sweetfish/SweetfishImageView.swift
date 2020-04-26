//
//  SweetfishImageView.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/15.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

public enum Result {
    case success(image: UIImage)
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

    public var isMaskImage: Bool {
        return subviews.count != 0
    }

    public func predict(objectType: ObjectType, completion: @escaping ((Result) -> Void)) {
        predictCompletionHandler = completion
        guard let image = image, let cgImage = image.cgImage else {
            predictCompletionHandler?(.failure(error: SweetfishError.cgImageNotFound))
            return
        }
        mlManager.predict(with: cgImage) {[weak self] mlMulutiArray, error in
            if let error = error {
                self?.predictCompletionHandler?(.failure(error: error))
            } else {
                self?.configureSegmentation(objectType: objectType, image: image, mlMulutiArray: mlMulutiArray) { result in
                    self?.predictCompletionHandler?(result)
                }
            }
        }
    }

    public func reset() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }

    private func configureSegmentation(objectType: ObjectType, image: UIImage, mlMulutiArray: SegmentationResultMLMultiArray?, completionHandler: @escaping ((Result) -> Void)) {
        DispatchQueue.main.async {
            let segmentationView = SegmentationView()
            self.addSubview(segmentationView)
            segmentationView.backgroundColor = .clear
            segmentationView.frame = self.imageFrame
            segmentationView.updateSegmentationMap(segmentationMap: mlMulutiArray, objectType: objectType) {segmentationResult in
                switch segmentationResult {
                case .success(let maskImage):
                    if let maskedImage = image.masking(maskImage: maskImage) {
                        completionHandler(.success(image: maskedImage))
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

extension UIImage {
    
    // 指定したマスク画像を利用して元画像を切り抜く
    // マスク画像は非透過画像を利用する (輝度情報からマスクを作成している模様)
    func masking(maskImage: UIImage?) -> UIImage? {
        guard let maskImage = maskImage?.cgImage else {
            return nil
        }
        
        //マスクを作成する
        let mask = CGImage(maskWidth: maskImage.width,
                           height: maskImage.height,
                           bitsPerComponent: maskImage.bitsPerComponent,
                           bitsPerPixel: maskImage.bitsPerPixel,
                           bytesPerRow: maskImage.bytesPerRow,
                           provider: maskImage.dataProvider!,
                           decode: nil, shouldInterpolate: false)!
        
        //マスクを適用する
        guard let maskedImage = self.cgImage?.masking(mask) else {
            return nil
        }
        return UIImage(cgImage: maskedImage)
    }
}
