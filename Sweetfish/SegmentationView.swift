//
//  SegmentationView.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/16.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

enum SegmentationResult {
    case success(maskImage: UIImage)
    case failure(error: Error)
}

final class SegmentationView: UIView {
    private var colors: [Int32: UIColor] = [:]
    private var completionHandler: ((SegmentationResult) -> Void)?
    private var clippingMethod: ClippingMethod = .object(objectType: .human)
    private(set) var segmentationmap: SegmentationResultMLMultiArray? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let segmentationmap = self.segmentationmap else {
            if UIGraphicsGetCurrentContext() == nil {
                completionHandler?(.failure(error: SweetfishError.graphicsCurrentContextNotFound))
            } else {
                completionHandler?(.failure(error: SweetfishError.segmentationmapNotFound))
            }
            return
        }
        context.clear(rect)
        let size = bounds.size
        let segmentationmapWidthSize = segmentationmap.segmentationmapWidthSize
        let segmentationmapHeightSize = segmentationmap.segmentationmapHeightSize
        let mappingWidth = size.width / CGFloat(segmentationmapWidthSize)
        let mappingHeight = size.height / CGFloat(segmentationmapHeightSize)

        for y in 0..<segmentationmapHeightSize {
            for x in 0..<segmentationmapWidthSize {
                let value = segmentationmap[y, x].int32Value

                let rect: CGRect = CGRect(x: CGFloat(x) * mappingWidth, y: CGFloat(y) * mappingHeight, width: mappingWidth*2, height: mappingHeight*2)

                let color: UIColor = segmentationColor(with: value)

                color.setFill()
                UIRectFill(rect)
                if y == (segmentationmapHeightSize-1) && x == (segmentationmapWidthSize-1) {
                    if let cgImage = context.makeImage() {
                        completionHandler?(.success(maskImage: UIImage.init(cgImage: cgImage)))
                    } else {
                        completionHandler?(.failure(error: SweetfishError.cgImageNotFound))
                    }
                }
            }
        }
    }

    func updateSegmentationMap(segmentationMap: SegmentationResultMLMultiArray?, clippingMethod: ClippingMethod, completionHandler: @escaping ((SegmentationResult) -> Void)) {
        self.segmentationmap = segmentationMap
        self.clippingMethod = clippingMethod
        self.completionHandler = completionHandler
    }

    func updateClippingMethod(clippingMethod: ClippingMethod, completionHandler: @escaping ((SegmentationResult) -> Void)) {
        self.clippingMethod = clippingMethod
        self.completionHandler = completionHandler
        self.setNeedsDisplay()
    }

    func createValueWithPoint(x: Int, y: Int) -> Int32 {
        return segmentationmap![y, x].int32Value
    }

    func segmentationColor(with index: Int32) -> UIColor {
        switch clippingMethod {
        case .object(let objectType):
            return (index == objectType.rawValue) ? .black : .white
        case .selectTouch:
            if let color = colors[index] {
                return color
            } else {
                let color = UIColor(hue: CGFloat(index) / CGFloat(30), saturation: 1, brightness: 1, alpha: 0.5)
                colors[index] = color
                return color
            }
        case .selectValue(let value):
            return (index == value) ? .black : .white
        }
    }
}
