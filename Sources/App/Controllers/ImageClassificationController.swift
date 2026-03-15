import SwiftOpenAPI
import Vapor
import Vision

struct ImageClassificationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let imageClassificationRoute = routes.grouped("image-classification")
        imageClassificationRoute.get("supported-identifiers", use: supportedIdentifiersRequest)
            .openAPI(
                description: """
                    Returns all category label identifiers supported by `VNClassifyImageRequest` \
                    under the current configuration (e.g. `dog`, `beach`, `food`).
                    The list reflects the exact set of identifiers that may appear in a `/classify` response.
                    """,
                response: .type(supportedIdentifiersResponse.self)
            )

        imageClassificationRoute.post("classify", use: classifyImageRequest)
            .openAPI(
                description: """
                    Classifies the content of an image using the Vision framework (`VNClassifyImageRequest`).
                    Returns a list of category labels (e.g. `dog`, `beach`, `food`) with confidence scores.
                    Use case: automatic image tagging, content pre-filtering.
                    """,
                body: .type(classifyImage.self),
                contentType: .multipart(.formData),
                response: .type(classifyImageResponse.self)
            )
    }

    @Sendable func supportedIdentifiersRequest(req: Request) async throws
        -> supportedIdentifiersResponse
    {
        do {
            let identifiers = try VNClassifyImageRequest().supportedIdentifiers()
                .sorted()
            return supportedIdentifiersResponse(identifiers: identifiers, count: identifiers.count)
        } catch {
            throw Abort(
                .internalServerError,
                reason: "Failed to retrieve supported identifiers: \(error).")
        }
    }

    @Sendable func classifyImageRequest(req: Request) async throws -> classifyImageResponse {
        let requestForm = try req.content.decode(classifyImage.self)

        let confidenceThreshold = requestForm.confidenceThreshold ?? 0.0
        let maxResults = requestForm.maxResults

        let requestHandler = VNImageRequestHandler(data: requestForm.imageFile.data)
        let classifyRequest = VNClassifyImageRequest()

        do {
            try requestHandler.perform([classifyRequest])
        } catch {
            throw Abort(
                .internalServerError, reason: "Failed to perform image classification: \(error).")
        }

        guard let observations = classifyRequest.results else {
            throw Abort(.internalServerError, reason: "No classification results returned.")
        }

        var classifications =
            observations
            .filter { $0.confidence >= Float(confidenceThreshold) }
            .sorted { $0.confidence > $1.confidence }
            .map { ClassificationResult(identifier: $0.identifier, confidence: $0.confidence) }

        if let maxResults, maxResults > 0 {
            classifications = Array(classifications.prefix(maxResults))
        }

        return classifyImageResponse(classifications: classifications)
    }
}

@OpenAPIDescriptable
struct classifyImage: Content {
    /// Image file to classify
    var imageFile: BinaryFile
    /// Minimum confidence threshold (0.0–1.0). Only labels at or above this value are returned. Defaults to 0.0 (return all).
    var confidenceThreshold: Double?
    /// Maximum number of results to return, sorted by confidence descending. Defaults to all results.
    var maxResults: Int?
}

struct ClassificationResult: Content {
    /// Category label (e.g. `dog`, `beach`, `food`)
    var identifier: String
    /// Confidence score in the range 0.0–1.0
    var confidence: Float
}

struct classifyImageResponse: Content {
    /// List of classification labels sorted by confidence descending
    var classifications: [ClassificationResult]
}

struct supportedIdentifiersResponse: Content {
    /// All category label identifiers supported by VNClassifyImageRequest, sorted alphabetically
    var identifiers: [String]
    /// Total number of supported identifiers
    var count: Int
}
