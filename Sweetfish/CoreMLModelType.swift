//
//  CoreMLModelType.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/15.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import Vision

enum CoreMLModelType {
    case deepLabV3
    case deepLabV3FP16
    case deepLabV3Int8LUT

    var model: MLModel {
        switch self {
        case .deepLabV3:
            return DeepLabV3().model
        case .deepLabV3FP16:
            return DeepLabV3FP16().model
        case .deepLabV3Int8LUT:
            return DeepLabV3Int8LUT().model
        }
    }
}
