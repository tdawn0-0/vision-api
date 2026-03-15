import SwiftOpenAPI
import Vapor
import Vision

struct BarcodeDetectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let detectionRoute = routes.grouped("barcode-detection")
        detectionRoute.post("detect", use: detectBarcodesRequest)
            .openAPI(
                description: "Detects barcodes and QR codes in an image.",
                body: .type(detectBarcodes.self),
                contentType: .multipart(.formData),
                response: .type([detectBarcodesResponse].self)
            )
        
        detectionRoute.get("symbologies", use: getSupportedSymbologies)
            .openAPI(
                description: "Returns all supported barcode symbologies.",
                response: .type([String].self)
            )
    }

    @Sendable func getSupportedSymbologies(req: Request) async throws -> [String] {
        let request = VNDetectBarcodesRequest()
        return try request.supportedSymbologies().map { $0.rawValue }
    }

    @Sendable func detectBarcodesRequest(req: Request) async throws -> [detectBarcodesResponse] {
        let requestForm = try req.content.decode(detectBarcodes.self)

        var detectedBarcodes: [detectBarcodesResponse] = []

        let requestHandler = VNImageRequestHandler(data: requestForm.imageFile.data)
        
        func detectBarcodesHandler(request: VNRequest, error: Error?) {
            guard let observations = request.results as? [VNBarcodeObservation] else {
                return
            }
            detectedBarcodes = observations.map { observation in
                detectBarcodesResponse(
                    payload: observation.payloadStringValue ?? "",
                    symbology: observation.symbology.rawValue
                )
            }
        }

        let barcodeRequest = VNDetectBarcodesRequest(completionHandler: detectBarcodesHandler)

        if let symbologiesStr = requestForm.symbologies {
            let supported = try barcodeRequest.supportedSymbologies()
            let symbologies = symbologiesStr.split(separator: ",").compactMap { sub -> VNBarcodeSymbology? in
                let rawValue = sub.trimmingCharacters(in: .whitespaces)
                let symbology = VNBarcodeSymbology(rawValue: rawValue)
                if supported.contains(symbology) {
                    return symbology
                } else {
                    print("Warning: '\(rawValue)' is not a supported barcode symbology on this device.")
                    return nil
                }
            }
            if !symbologies.isEmpty {
                barcodeRequest.symbologies = symbologies
            }
        }

        do {
            try requestHandler.perform([barcodeRequest])
        } catch {
            print("Unable to perform the requests: \(error).")
        }

        return detectedBarcodes
    }
}

@OpenAPIDescriptable
struct detectBarcodes: Content {
    /// image file
    var imageFile: BinaryFile
    /// comma-separated symbologies. 
    /// Full list of supported values:
    /// - VNBarcodeSymbologyAztec
    /// - VNBarcodeSymbologyCodabar
    /// - VNBarcodeSymbologyCode39
    /// - VNBarcodeSymbologyCode39Checksum
    /// - VNBarcodeSymbologyCode39FullASCII
    /// - VNBarcodeSymbologyCode39FullASCIIChecksum
    /// - VNBarcodeSymbologyCode93
    /// - VNBarcodeSymbologyCode93i
    /// - VNBarcodeSymbologyCode128
    /// - VNBarcodeSymbologyDataMatrix
    /// - VNBarcodeSymbologyEAN8
    /// - VNBarcodeSymbologyEAN13
    /// - VNBarcodeSymbologyGS1DataBar
    /// - VNBarcodeSymbologyGS1DataBarExpanded
    /// - VNBarcodeSymbologyGS1DataBarLimited
    /// - VNBarcodeSymbologyI2of5
    /// - VNBarcodeSymbologyI2of5Checksum
    /// - VNBarcodeSymbologyITF14
    /// - VNBarcodeSymbologyMicroPDF417
    /// - VNBarcodeSymbologyMicroQR
    /// - VNBarcodeSymbologyMSIPlessey
    /// - VNBarcodeSymbologyPDF417
    /// - VNBarcodeSymbologyQR
    /// - VNBarcodeSymbologyUPCE
    /// 
    /// You can also call GET /barcode-detection/symbologies to get the list supported by the current system.
    var symbologies: String?
}

struct detectBarcodesResponse: Content {
    var payload: String
    var symbology: String
}
