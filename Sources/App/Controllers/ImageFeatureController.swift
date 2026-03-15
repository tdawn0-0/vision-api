import CoreGraphics
import CoreImage
import ImageIO
import SwiftOpenAPI
import UniformTypeIdentifiers
import Vapor
import Vision

@available(macOS 15.0, *)
struct ImageFeatureController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let imageFeatureRoute = routes.grouped("image-feature")
        imageFeatureRoute.post("background-removal", use: backgroundRemovalRequest)
            .openAPI(
                description: "Remove image background.",
                body: .type(backgroundRemoval.self),
                contentType: .multipart(.formData),
                response: .type(Data.self),
                responseContentType: MediaType("image", "png")
            )

        imageFeatureRoute.post("aesthetics-scoring", use: aestheticsScoringRequest)
            .openAPI(
                description:
                    "Calculate aesthetic scores for an image. Returns an overallScore (-1 to 1) and whether the image is a utility image (screenshot, receipt, document, etc.).",
                body: .type(aestheticsScoring.self),
                contentType: .multipart(.formData),
                response: .type(aestheticsScoringResponse.self)
            )
    }

    @Sendable func backgroundRemovalRequest(req: Request) async throws -> Response {
        let requestForm = try req.content.decode(backgroundRemoval.self)

        let handler = VNImageRequestHandler(data: requestForm.imageFile.data)
        let request = VNGenerateForegroundInstanceMaskRequest()

        try handler.perform([request])

        guard let observation = request.results?.first,
            !observation.allInstances.isEmpty
        else {
            throw Abort(.internalServerError, reason: "No foreground instance found.")
        }

        let finalImage = try observation.generateMaskedImage(
            ofInstances: IndexSet(integersIn: 1...observation.allInstances.count),
            from: VNImageRequestHandler(data: requestForm.imageFile.data),
            croppedToInstancesExtent: true
        )

        let ciImage = CIImage(cvPixelBuffer: finalImage)
        let context = CIContext(options: nil)

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw Abort(.internalServerError, reason: "Failed to convert image.")
        }

        let data = NSMutableData()
        guard
            let imageDestination = CGImageDestinationCreateWithData(
                data, UTType.png.identifier as CFString, 1, nil)
        else {
            throw Abort(.internalServerError, reason: "Failed to create image destination.")
        }

        CGImageDestinationAddImage(imageDestination, cgImage, nil)
        CGImageDestinationFinalize(imageDestination)

        let response = Response(status: .ok, body: .init(data: data as Data))
        response.headers.contentType = .png
        response.headers.contentDisposition = .init(.attachment, filename: "image.png")
        return response
    }

    @Sendable func aestheticsScoringRequest(req: Request) async throws -> aestheticsScoringResponse
    {
        let requestForm = try req.content.decode(aestheticsScoring.self)

        let request = CalculateImageAestheticsScoresRequest()
        let observation = try await request.perform(on: requestForm.imageFile.data)

        return aestheticsScoringResponse(
            overallScore: observation.overallScore,
            isUtility: observation.isUtility
        )
    }
}

@OpenAPIDescriptable
struct backgroundRemoval: Content {
    /// image file
    var imageFile: BinaryFile
}

@OpenAPIDescriptable
struct aestheticsScoring: Content {
    /// image file
    var imageFile: BinaryFile
}

struct aestheticsScoringResponse: Content {
    /// Overall aesthetic score ranging from -1.0 (low quality) to 1.0 (high quality).
    /// Based on factors such as blur, exposure, color balance, composition, and subject matter.
    var overallScore: Float
    /// Whether the image is a utility image (e.g. screenshot, receipt, document)
    /// rather than an artistic or personal photo.
    var isUtility: Bool
}
