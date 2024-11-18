import Vapor
import Vision

struct TextDetectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let textDetectionRoute = routes.grouped("textDetection")
        textDetectionRoute.post("recognizeText", use: recognizeTextRequest)
            .openAPI(
                description: "recognitionLanguages field is split by comma. For example: zh,en",
                body: .type(recognizeText.self),
                contentType: .multipart(.formData),
                response: .type(recognizeTextResponse.self)
            )
    }

    @Sendable func recognizeTextRequest(req: Request) async throws -> recognizeTextResponse {
        let requestForm = try req.content.decode(recognizeText.self)
        let recognitionLanguages: [String] = requestForm.recognitionLanguages.split(separator: ",").map { String($0) }
        var textString = ""
        let requestHandler = VNImageRequestHandler(data: requestForm.imageFile)
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

        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLanguages = recognitionLanguages
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
            textString = "Unable to perform the requests: \(error)."
        }

        return recognizeTextResponse(text: textString)
    }
}

struct recognizeText: Content {
    var imageFile: Data
    var recognitionLanguages: String
}

struct recognizeTextResponse: Content {
    var text: String
}
