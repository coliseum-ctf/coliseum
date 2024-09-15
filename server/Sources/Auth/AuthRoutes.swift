import Vapor

extension AuthConfiguration {
    public func useRoutes() {
        self.app.group("api") { routes in
            routes.post("login") { request in
                return Response(status: .ok)
            }
        }
    }
}
