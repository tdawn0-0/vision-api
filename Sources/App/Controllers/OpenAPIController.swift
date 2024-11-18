import Foundation
import Vapor
import VaporToOpenAPI

struct OpenAPIController: RouteCollection {

    // MARK: Internal

    func boot(routes: RoutesBuilder) throws {

        // generate OpenAPI documentation
        routes.get("Swagger", "swagger.json") { req in
            req.application.routes.openAPI(
                info: InfoObject(
                    title: "Vision Restful API - OpenAPI",
                    version: Version(0, 0, 1)
                )
            )
        }
        .excludeFromOpenAPI()

        routes.stoplightDocumentation(
            "stoplight",
            openAPIPath: "/swagger/swagger.json"
        )
    }
}
