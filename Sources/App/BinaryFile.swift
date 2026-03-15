import Foundation
import SwiftOpenAPI
import Vapor

/// A wrapper around `Data` that maps to `string(binary)` in the OpenAPI schema,
/// causing Swagger UI to render the field as a file-chooser input rather than
/// a base64 text box (which is what the bare `Data` / `string(byte)` format produces).
struct BinaryFile: Codable, OpenAPIType, Sendable {

    // MARK: Lifecycle

    init(_ data: Data) {
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        data = try container.decode(Data.self)
    }

    // MARK: Internal

    /// The underlying raw bytes of the uploaded file.
    let data: Data

    /// Override the default OpenAPI schema so the field appears as a binary file
    /// upload (`string(binary)`) rather than a base64-encoded string (`string(byte)`).
    static var openAPISchema: SchemaObject {
        .string(format: "binary")
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }
}
