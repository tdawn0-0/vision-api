import Vapor
import Vision
import SwiftOpenAPI

struct TextDetectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let textDetectionRoute = routes.grouped("textDetection")
        textDetectionRoute.post("recognizeText", use: recognizeTextRequest)
            .openAPI(
                description: "The recognitionLanguages field is optional and should be separated by commas if provided. For example: zh,en.",
                body: .type(recognizeText.self),
                contentType: .application(.json),
                response: .type(recognizeTextResponse.self)
            )
    }

    @Sendable func recognizeTextRequest(req: Request) async throws -> recognizeTextResponse {
        let requestForm = try req.content.decode(recognizeText.self)

        var textString = ""
        guard let imageData = Data(base64Encoded: requestForm.imageBase64) else {
            return recognizeTextResponse(text: "Invalid image data")
        }

        let requestHandler = VNImageRequestHandler(data: imageData)
        func recognizeTextHandler(request: VNRequest, error: Error?) {
            guard let observations =
                request.results as? [VNRecognizedTextObservation]
            else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            textString = recognizedStrings.joined(separator: "\n")
        }

        let textRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        if let languages = requestForm.recognitionLanguages {
            textRequest.recognitionLanguages = languages
        } else {
            textRequest.automaticallyDetectsLanguage = true
        }

        if requestForm.recognitionLevel == 1 {
            textRequest.recognitionLevel = .fast
        }

        do {
            try requestHandler.perform([textRequest])
        } catch {
            print("Unable to perform the requests: \(error).")
            textString = "Unable to perform the requests: \(error)."
        }

        return recognizeTextResponse(text: textString)
    }
}

@OpenAPIDescriptable
struct recognizeText: Content {
    /// image string encoded by base64
    var imageBase64: String
    /// recognitionLanguages ISO language codes. For example: [zh, en]
    var recognitionLanguages: [String]?
    /// recognitionLevel "0 = accurate" or "1 = fast", default is "accurate".
    var recognitionLevel: Int?
}

struct recognizeTextResponse: Content {
    var text: String
}
