import SwiftOpenAPI
import Vapor
import Vision

struct TextDetectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let textDetectionRoute = routes.grouped("text-detection")
        textDetectionRoute.post("recognize-text", use: recognizeTextRequest)
            .openAPI(
                description: "Recognizes text in an image (OCR).",
                body: .type(recognizeText.self),
                contentType: .multipart(.formData),
                response: .type(recognizeTextResponse.self)
            )
    }

    @Sendable func recognizeTextRequest(req: Request) async throws -> recognizeTextResponse {
        let requestForm = try req.content.decode(recognizeText.self)

        var textString = ""

        let requestHandler = VNImageRequestHandler(data: requestForm.imageFile.data)
        func recognizeTextHandler(request: VNRequest, error: Error?) {
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            textString = recognizedStrings.joined(separator: "\n")
        }

        let textRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

        if let languages = requestForm.recognitionLanguages {
            textRequest.recognitionLanguages = languages.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespaces)
            }
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
    /// image file
    var imageFile: BinaryFile
    /// comma-separated recognition language ISO codes, e.g. "zh-Hans,en-US"
    var recognitionLanguages: String?
    /// recognition level: 0 = accurate (default), 1 = fast
    var recognitionLevel: Int?
}

struct recognizeTextResponse: Content {
    var text: String
}
