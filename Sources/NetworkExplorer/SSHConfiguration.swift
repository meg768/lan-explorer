import Foundation

enum SSHConfiguration {
    // Keep normal Mac SSH access first, then the original device accounts.
    static let connectionUsers: [String?] = [nil, "pi", "root"]

    static func arguments(user: String?, host: String) -> [String] {
        ["-n", "-T",
         "-o", "BatchMode=yes",
         "-o", "ConnectTimeout=4",
         "-o", "StrictHostKeyChecking=accept-new",
         "-o", "ClearAllForwardings=yes",
         "-o", "ForwardAgent=no",
         "-o", "ForwardX11=no",
         "-o", "PermitLocalCommand=no",
         "--", user.map { "\($0)@\(host)" } ?? host]
    }
}
