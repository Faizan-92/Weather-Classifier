//
//  ViewController.swift
//  ML App
//
//  Created by Faizan Memon on 09/04/23.
//

import UIKit
import CoreML
import Photos
import Vision

class ViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    @IBOutlet weak var inputImageView: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!

    var model: VNCoreMLModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        model = getWeatherClassifierModel()
    }

    @IBAction func pickImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        inputImageView.image = selectedImage
        inputImageView.isHidden = false
        dismiss(animated: true) { [weak self] in
            self?.classifyImage()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func getWeatherClassifierModel() -> VNCoreMLModel? {
        
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()

        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? Weather_Classifier_Model(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }

        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }

        return imageClassifierVisionModel
    }

    func classifyImage() {
        guard let cgImage = inputImageView.image?.cgImage,
              let model = model else {
            return
        }

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: .up
        )

        // Create an image classification request with an image classifier model.
        let imageClassificationRequest = VNCoreMLRequest(
            model: model,
            completionHandler: { [weak self] request, _ in
                // Cast the request's results as an `VNClassificationObservation` array.
                guard let observations = request.results as? [VNClassificationObservation] else {
                    // Image classifiers, like MobileNet, only produce classification observations.
                    // However, other Core ML model types can produce other observations.
                    // For example, a style transfer model produces `VNPixelBufferObservation` instances.
                    print("VNRequest produced the wrong result type: \(type(of: request.results)).")
                    return
                }

                // Create a prediction array from the observations.
                let prediction = observations.max(by: { $0.confidence < $1.confidence })?.identifier
                self?.predictionLabel.text = prediction?.capitalized
                self?.predictionLabel.isHidden = false
            }
        )

        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        
        let requests: [VNRequest] = [imageClassificationRequest]
        try? handler.perform(requests)
    }
}

