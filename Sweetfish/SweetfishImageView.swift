//
//  SweetfishImageView.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/15.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

public final class SweetfishImageView: UIImageView {
    private var mlManager = CoreMLManager.init(type: .deepLabV3)
    private var predictCompletionHandler: ((Error?) -> Void)?
    private var colors: [Int32: UIColor] = [:]

    var mlModelType: CoreMLModelType = .deepLabV3 {
        didSet {
            self.mlManager = CoreMLManager.init(type: mlModelType)
        }
    }

    var mlMulutiArray: SegmentationResultMLMultiArray? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }

    func predict(completion: @escaping ((Error?) -> Void)) {
        self.predictCompletionHandler = completion
        guard let cgImage = image?.cgImage else {
            // TODO: Add Error.
            self.predictCompletionHandler?(nil)
            return
        }
        mlManager.predict(with: cgImage) {[weak self] mlMulutiArray, error in
            if let error = error {
                self?.predictCompletionHandler?(error)
            } else {
                self?.mlMulutiArray = mlMulutiArray
            }
        }
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let segmentationmap = self.mlMulutiArray else {
            // TODO: Add Error.
            self.predictCompletionHandler?(nil)
            return
        }
        context.clear(rect)
        let size = self.bounds.size
        let segmentationmapWidthSize = segmentationmap.segmentationmapWidthSize
        let segmentationmapHeightSize = segmentationmap.segmentationmapHeightSize
        let w = size.width / CGFloat(segmentationmapWidthSize)
        let h = size.height / CGFloat(segmentationmapHeightSize)

        for j in 0..<segmentationmapHeightSize {
            for i in 0..<segmentationmapWidthSize {
                let value = segmentationmap[j, i].int32Value

                let rect: CGRect = CGRect(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w*2, height: h*2)

                let color: UIColor = segmentationColor(with: value)

                color.setFill()
                UIRectFill(rect)
                if i == (segmentationmapWidthSize-1) {
                    self.predictCompletionHandler?(nil)
                }
            }
        }
    }

    func segmentationColor(with index: Int32) -> UIColor {
        if index == 3 {
            return UIColor.clear
        } else {
            return .white
        }
    }
}

