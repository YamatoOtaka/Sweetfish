//
//  CoreMLManager.swift
//  Sweetfish
//
//  Created by 大高倭 on 2020/04/15.
//  Copyright © 2020 YamatoOtaka. All rights reserved.
//

import Vision

final class CoreMLManager {
    private let segmentationModel: MLModel
    private var visionModel: VNCoreMLModel?
    private var visionRequest: VNCoreMLRequest?
    private var completionHandler: ((_ :SegmentationResultMLMultiArray?,_ error: Error?) -> Void)?

    init(type: CoreMLModelType) {
        segmentationModel = type.model
        setupVisionRequest()
    }

    func predict(with cgImage: CGImage, completionHandler: @escaping ((_ :SegmentationResultMLMultiArray?,_ error: Error?) -> Void)) {
        guard let request = visionRequest else { return }
        self.completionHandler = completionHandler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    private func setupVisionRequest() {
        guard let visionModel = try? VNCoreMLModel.init(for: segmentationModel) else { return }
        self.visionModel = visionModel
        visionRequest = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestCompletionHandler)
        visionRequest?.imageCropAndScaleOption = .centerCrop
    }

    private func visionRequestCompletionHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation], let mlMulutiArray = observations.first?.featureValue.multiArrayValue else {
            completionHandler?(nil, error)
            return
        }
        completionHandler?(SegmentationResultMLMultiArray.init(mlMultiArray: mlMulutiArray), error)
    }
}

final class SegmentationResultMLMultiArray {
    let mlMultiArray: MLMultiArray
    let segmentationmapWidthSize: Int
    let segmentationmapHeightSize: Int

    init(mlMultiArray: MLMultiArray) {
        self.mlMultiArray = mlMultiArray
        self.segmentationmapWidthSize = mlMultiArray.shape[0].intValue
        self.segmentationmapHeightSize = mlMultiArray.shape[1].intValue
    }

    subscript(colunmIndex: Int, rowIndex: Int) -> NSNumber {
        let index = colunmIndex*(segmentationmapHeightSize) + rowIndex
        return mlMultiArray[index]
    }
}
