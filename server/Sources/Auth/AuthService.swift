import Vapor

public struct AuthConfiguration {
    internal var app: Application
    public var signingKey: String = "secret"
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
