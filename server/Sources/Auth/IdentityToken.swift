import Vapor
import JWT

public struct IdentityToken: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuer = "iss"
        case issuedAt = "iat"
    }

    public var subject: SubjectClaim
    public var expiration: ExpirationClaim
    public var issuer: IssuerClaim
    public var issuedAt: IssuedAtClaim

    public func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
