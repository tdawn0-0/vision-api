import Vapor

func routes(_ app: Application) throws {
    app.routes.defaultMaxBodySize = "20mb"

    app.get { req async in
        req.redirect(to: "/Swagger/index.html")
    }

    try app.register(collection: TextDetectionController())
    if #available(macOS 15.0, *) {
        try app.register(collection: ImageFeatureController())
    } else {
        // Fallback on earlier versions
    }
    try app.register(collection: OpenAPIController())
}
