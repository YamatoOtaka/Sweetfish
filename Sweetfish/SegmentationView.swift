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
    private var completionHandler: ((SegmentationResult) -> Void)?
    private var objectType: ObjectType = .human
    private var segmentationmap: SegmentationResultMLMultiArray? = nil {
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

    func updateSegmentationMap(segmentationMap: SegmentationResultMLMultiArray?, objectType: ObjectType, completionHandler: @escaping ((SegmentationResult) -> Void)) {
        self.segmentationmap = segmentationMap
        self.objectType = objectType
        self.completionHandler = completionHandler
    }

    private func segmentationColor(with index: Int32) -> UIColor {
        if index == objectType.rawValue {
            return UIColor.black
        } else {
            if let superviewBackgroundColor = superview?.backgroundColor, superviewBackgroundColor != .clear {
                return superviewBackgroundColor
            }
            return .white
        }
    }

    // UIViewからUIImageに変更する
    func viewToImage(_ view : UIView) -> UIImage {
        
        // キャプチャする範囲を取得する
        let rect = view.bounds
        
        // 画像のcontextを作成する
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        
        // contextを取得する
        let context : CGContext = UIGraphicsGetCurrentContext()!
        
        // view内の描画をcontextに複写する
        view.layer.render(in: context)
        
        // contextをUIImageとして取得する
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // contextを閉じる
        UIGraphicsEndImageContext()
        
        return image
    }
}
