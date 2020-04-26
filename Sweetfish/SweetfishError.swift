//
//  SweetfishError.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/20.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

public enum SweetfishError: Error, LocalizedError {
    case cgImageNotFound
    case visionRequestNotFound
    case perform
    case graphicsCurrentContextNotFound
    case segmentationmapNotFound
    case maskingImageRetrieved

    public var errorDescription: String? {
        switch self {
        case .cgImageNotFound: return "The specified image was not found."
        case .visionRequestNotFound: return "Could not find VNCoreMLRequest in CoreMLManager."
        case .perform: return "Failed to perform VNImageRequestHandler."
        case .graphicsCurrentContextNotFound: return "UIGraphicsGetCurrentContext could not be obtained."
        case .segmentationmapNotFound: return "Could not get segmentation map in SegmentationView."
        case .maskingImageRetrieved: return "The masked image could not be retrieved."
        }
    }
}
