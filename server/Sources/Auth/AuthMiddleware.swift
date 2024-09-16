import Vapor

public struct AuthMiddleware: AsyncMiddleware {
    public init() {
    }
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        return try await next.respond(to: request)
    }
}
