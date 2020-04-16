//
//  SegmentationView.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/16.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

final class SegmentationView: UIView {
    var segmentationmap: SegmentationResultMLMultiArray? = nil {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let segmentationmap = self.segmentationmap else { return }
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
            }
        }
    }

    private func segmentationColor(with index: Int32) -> UIColor {
        if index == 3 {
            return UIColor.clear
        } else {
            if let superviewBackgroundColor = superview?.backgroundColor, superviewBackgroundColor != .clear {
                return superviewBackgroundColor
            }
            return .white
        }
    }
}
