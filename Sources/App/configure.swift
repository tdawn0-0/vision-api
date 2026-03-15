import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(
        FileMiddleware(publicDirectory: app.directory.publicDirectory, defaultFile: "index.html"))

    // Default port is 9493.
    // Override priority (highest → lowest):
    //   1. --port <value>  CLI flag  (handled automatically by Vapor's ServeCommand)
    //   2. PORT            environment variable
    //   3. 9493            built-in default
    if let portString = Environment.get("PORT"), let port = Int(portString) {
        app.http.server.configuration.port = port
    } else {
        app.http.server.configuration.port = 9493
    }

    // register routes
    try routes(app)
}
