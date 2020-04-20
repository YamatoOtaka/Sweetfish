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
        self.completionHandler = completionHandler
        DispatchQueue.global(qos: .background).async {[weak self] in
            guard let request = self?.visionRequest else {
                self?.completionHandler?(nil, SweetfishError.visionRequestNotFound)
                return
            }
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                self?.completionHandler?(nil, SweetfishError.perform)
            }
        }
    }

    private func setupVisionRequest() {
        guard let visionModel = try? VNCoreMLModel.init(for: segmentationModel) else { return }
        self.visionModel = visionModel
        visionRequest = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestCompletionHandler)
        visionRequest?.imageCropAndScaleOption = .scaleFit
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
