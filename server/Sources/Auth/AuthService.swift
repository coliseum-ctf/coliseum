import Vapor

public struct AuthConfiguration {
    internal var app: Application
    public var issuer: String = "auth-service"
    public var expiration: Double = 600
    public var signingKey: String = "secret"
    public var emailVerifier: (String) async throws -> Bool = { _ in true }
    public var loginHandler: (Request, String) async throws -> Void = { _, _ in }

    public mutating func onLogin(_ handler: @escaping (Request, String) async throws -> Void) {
        self.loginHandler = handler
    }

    public mutating func useEmailVerifier(_ verifier: @escaping (String) async throws -> Bool) {
        self.emailVerifier = verifier
    }
}

public struct AuthConfigurationKey: StorageKey {
    public typealias Value = AuthConfiguration
}

extension Application {
    public var auth: AuthConfiguration {
        get {
            self.storage[AuthConfigurationKey.self] ?? AuthConfiguration.init(app: self)
        }
        set {
            self.storage[AuthConfigurationKey.self] = newValue
        }
    }
}
