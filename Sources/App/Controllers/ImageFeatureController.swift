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
                response: .type(backgroundRemovalResponse.self),
                responseContentType: MediaType("image", "png")
            )
    }

    @Sendable func backgroundRemovalRequest(req: Request) async throws -> Response {
        let requestForm = try req.content.decode(backgroundRemoval.self)
        
        let handler = VNImageRequestHandler(data: requestForm.imageFile)
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        try handler.perform([request])
        
        guard let observation = request.results?.first else {
            return Response(status: .internalServerError, body: .init(stringLiteral: "No foreground instance found."))
        }
        
        if observation.allInstances.count < 1 {
            return Response(status: .internalServerError, body: .init(stringLiteral: "No foreground instance found."))
        }
        
        let handler2 = VNImageRequestHandler(data: requestForm.imageFile)
        let finalImage = try observation.generateMaskedImage(ofInstances: IndexSet(integersIn: 1 ... observation.allInstances.count + 1), from: handler2, croppedToInstancesExtent: true)
        
        let ciImage = CIImage(cvPixelBuffer: finalImage)
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return Response(status: .internalServerError, body: .init(stringLiteral: "Failed to convert image."))
        }
        let data = NSMutableData()
        let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil)
        guard let unwrappedImageDestination = imageDestination else {
            return Response(status: .internalServerError, body: .init(stringLiteral: "Failed to create image destination."))
        }
        CGImageDestinationAddImage(unwrappedImageDestination, cgImage, nil)
        CGImageDestinationFinalize(unwrappedImageDestination)
        let pngData = data as Data
        
        let response = Response(status: .ok, body: .init(data: pngData))
        response.headers.contentType = .png
        response.headers.contentDisposition = .init(HTTPHeaders.ContentDisposition.Value.attachment, filename: "image.png")
        return response
    }
}

@OpenAPIDescriptable
struct backgroundRemoval: Content {
    /// image file
    var imageFile: Data
}

struct backgroundRemovalResponse: Content {
    var text: String
}
