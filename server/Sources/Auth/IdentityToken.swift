import Vapor
import JWT

struct IdentityToken: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
        case issuer = "iss"
        case issuedAt = "iat"
    }

    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var issuer: IssuerClaim
    var issuedAt: IssuedAtClaim

    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}
