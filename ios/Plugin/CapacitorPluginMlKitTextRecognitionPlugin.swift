import Foundation
import Capacitor
import CoreGraphics
import Vision
/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapacitorPluginAITextRecognitionPlugin)
public class CapacitorPluginAITextRecognitionPlugin: CAPPlugin {

    var _call:CAPPluginCall!

    @objc func detectText(_ call: CAPPluginCall) {
        self._call = call;

        guard let encodedImage = call.getString("base64Image") else {
            call.reject("No image is given!")
            return
        }
        let r = call.getInt("rotation") ?? 0
        let rotation = UInt32(r)
        guard let orientation = CGImagePropertyOrientation.init(rawValue: rotation) else { return  }

        let dataDecoded : Data = Data(base64Encoded: encodedImage, options: .ignoreUnknownCharacters)!
        guard let image = UIImage(data: dataDecoded)?.cgImage else {
            call.reject("Unable to parse image")
            return
        }


        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .accurate


        let requests = [request]
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("Error: \(error)")
                call.reject("Error: \(error)")

            }
        }
    }

    func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            print("ERROR: \(error)")
            return
        }
        guard let results = request?.results, results.count > 0 else {
            print("No text found")
            return
        }

        let textBlocks = NSMutableArray()
        var allText = ""

        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    
                    let elements = text.string.split(separator: /\w/).map { Substring in
                        return [
                            "text": Substring,
                            "boundingBox": [
                                "left": text.accessibilityFrame.minX,
                                "top": text.accessibilityFrame.maxY,
                                "right": text.accessibilityFrame.maxX,
                                "bottom": text.accessibilityFrame.minY,
                            ],
                            "recognizedLanguage": text.accessibilityLanguage ?? ""
                        ]
                    }
                    
                    textBlocks.add([
                        "text": text.string,
                        "boundingBox": [
                            "left": text.accessibilityFrame.minX,
                            "top": text.accessibilityFrame.maxY,
                            "right": text.accessibilityFrame.maxX,
                            "bottom": text.accessibilityFrame.minY,
                        ],
                        "recognizedLanguage": text.accessibilityLanguage ?? "",
                        "lines": NSMutableArray(object: [
                            "text": text.string,
                            "boundingBox": [
                                "left": text.accessibilityFrame.minX,
                                "top": text.accessibilityFrame.maxY,
                                "right": text.accessibilityFrame.maxX,
                                "bottom": text.accessibilityFrame.minY,
                            ],
                            "recognizedLanguage": text.accessibilityLanguage ?? "",
                            "elemens":elements
                        ])
                      ])

                    allText = allText + " " + text.string

                }
            }
        }


        self._call.resolve([
            "text": allText,
          "blocks": textBlocks
        ])

    }

    public func visionImageOrientation(rotation: Int) -> UIImage.Orientation {
        switch rotation {
        case 0:
            return .up
        case 90:
            return .left
        case 180:
            return .down
        case 270:
            return .right
        default:
            return .up
        }
    }
}
