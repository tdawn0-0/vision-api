import Vapor

func routes(_ app: Application) throws {
    app.routes.defaultMaxBodySize = "20mb"

    app.get { req async in
        req.redirect(to: "/Swagger/index.html")
    }

    try app.register(collection: TextDetectionController())
    try app.register(collection: OpenAPIController())
}
