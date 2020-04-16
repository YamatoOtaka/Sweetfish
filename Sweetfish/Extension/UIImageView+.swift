//
//  UIImageView+.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/16.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImageView {
    var imageFrame: CGRect {
        guard let image = image else { return CGRect.zero }
        let imageSize = AVMakeRect(aspectRatio: image.size, insideRect: bounds)
        return imageSize
    }
}
