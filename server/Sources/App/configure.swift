import Vapor
import Auth

public func configure(_ app: Application) async throws {
    let corsConfiguration = CORSMiddleware.Configuration(
      allowedOrigin: .all,
      allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
      allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )

    app.middleware.use(CORSMiddleware(configuration: corsConfiguration), at: .beginning)
    app.middleware.use(AuthMiddleware())

    // register routes
    try routes(app)
}
