import Vapor

// configures your application
public func configure(_ app: Application) async throws {
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory, defaultFile: "index.html"))
    // register routes
    try routes(app)
}
