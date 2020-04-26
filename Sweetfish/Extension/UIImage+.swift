//
//  UIImage+.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/26.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import UIKit

extension UIImage {

    func masking(maskImage: UIImage?) -> UIImage? {
        guard let maskImage = maskImage?.cgImage, let dataProvider = maskImage.dataProvider else {
            return nil
        }
        let optionalMask = CGImage(maskWidth: maskImage.width,
                           height: maskImage.height,
                           bitsPerComponent: maskImage.bitsPerComponent,
                           bitsPerPixel: maskImage.bitsPerPixel,
                           bytesPerRow: maskImage.bytesPerRow,
                           provider: dataProvider,
                           decode: nil, shouldInterpolate: false)
        guard let mask = optionalMask, let maskedImage = self.cgImage?.masking(mask) else {
            return nil
        }
        return UIImage(cgImage: maskedImage)
    }
}
