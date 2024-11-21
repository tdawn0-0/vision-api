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
    }

    @Sendable func backgroundRemovalRequest(req: Request) async throws -> Response {
        let requestForm = try req.content.decode(backgroundRemoval.self)

        let handler = VNImageRequestHandler(data: requestForm.imageFile)
        let request = VNGenerateForegroundInstanceMaskRequest()

        try handler.perform([request])

        guard let observation = request.results?.first,
              !observation.allInstances.isEmpty
        else {
            throw Abort(.internalServerError, reason: "No foreground instance found.")
        }

        let finalImage = try observation.generateMaskedImage(
            ofInstances: IndexSet(integersIn: 1 ... observation.allInstances.count),
            from: VNImageRequestHandler(data: requestForm.imageFile),
            croppedToInstancesExtent: true
        )

        let ciImage = CIImage(cvPixelBuffer: finalImage)
        let context = CIContext(options: nil)

        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw Abort(.internalServerError, reason: "Failed to convert image.")
        }

        let data = NSMutableData()
        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            throw Abort(.internalServerError, reason: "Failed to create image destination.")
        }

        CGImageDestinationAddImage(imageDestination, cgImage, nil)
        CGImageDestinationFinalize(imageDestination)

        let response = Response(status: .ok, body: .init(data: data as Data))
        response.headers.contentType = .png
        response.headers.contentDisposition = .init(.attachment, filename: "image.png")
        return response
    }
}

@OpenAPIDescriptable
struct backgroundRemoval: Content {
    /// image file
    var imageFile: Data
}
