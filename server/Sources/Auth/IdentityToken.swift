import Vapor
import JWT
import Redis

public struct IdentityToken: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuer = "iss"
        case issuedAt = "iat"
        case token = "token"
    }

    public var subject: SubjectClaim
    public var expiration: ExpirationClaim
    public var issuer: IssuerClaim
    public var issuedAt: IssuedAtClaim
    public var token: String

    internal init(subject: SubjectClaim, expiration: ExpirationClaim, issuer: IssuerClaim, issuedAt: IssuedAtClaim) {
        self.subject = subject
        self.expiration = expiration
        self.issuer = issuer
        self.issuedAt = issuedAt
        self.token = generateToken()
    }

    public func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }

    public func signed(_ req: Request) throws -> String {
        try req.jwt.sign(self)
    }

    public static func issue(to: String, _ req: Request) async throws -> (String, String) {
        let expiration = ExpirationClaim(value: Date().addingTimeInterval(req.application.auth.expiration))
        let issuer = IssuerClaim(value: req.application.auth.issuer)
        let issuedAt = IssuedAtClaim(value: Date())
        let token = IdentityToken(subject: SubjectClaim(value: to), expiration: expiration, issuer: issuer, issuedAt: issuedAt)
        let refreshToken = generateToken()
        try await req.redis.setex(.init(refreshToken), to: token.token, expirationInSeconds: 86400 * 30).get()
        return (try req.jwt.sign(token), refreshToken)
    }

    public static func refresh(token refreshToken: String, _ req: Request) async throws -> (String, String) {
        let unverifiedToken = try req.jwt.verify(as: UnverifiedIdentityToken.self)
        if  try await req.redis.get(.init(refreshToken), as: String.self).get() != unverifiedToken.token {
            throw Abort(.forbidden)
        }
        try await IdentityToken.revoke(req)
        return try await issue(to: unverifiedToken.subject.value, req)
    }

    public static func revoke(_ req: Request) async throws {
        let unverifiedToken = try req.jwt.verify(as: UnverifiedIdentityToken.self)
        let timeLeft = unverifiedToken.expiration.value.timeIntervalSince(Date())
        if timeLeft > 0 {
            try await req.redis.setex(.init(unverifiedToken.token), to: "no", expirationInSeconds: Int(timeLeft)).get()
        }
    }

    public static func verify(_ req: Request) async throws -> IdentityToken {
        let identityToken = try req.jwt.verify(as: IdentityToken.self)
        if try await req.redis.get(.init(identityToken.token), as: String.self).get() == nil {
            throw Abort(.forbidden)
        }
        return identityToken
    }
}

extension Request {
    public func identityToken() async throws -> IdentityToken {
        try await IdentityToken.verify(self)
    }
}

fileprivate func generateToken() -> String {
    let alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<32).map { _ in alphabet.randomElement()! })
}

fileprivate struct UnverifiedIdentityToken: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuer = "iss"
        case issuedAt = "iat"
        case token = "token"
    }

    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var issuer: IssuerClaim
    var issuedAt: IssuedAtClaim
    var token: String

    func verify(using signer: JWTSigner) throws {
        // no-op
    }
}
