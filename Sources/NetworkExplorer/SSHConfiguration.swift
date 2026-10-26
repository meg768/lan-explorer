import Foundation

enum SSHConfiguration {
    // Keep normal Mac SSH access first, then the original device accounts.
    static let connectionUsers: [String?] = [nil, "pi", "root"]

    static func terminalURL(user: String?, host: String) -> URL? {
        let octets = host.split(separator: ".", omittingEmptySubsequences: false)
        guard octets.count == 4, octets.allSatisfy({
            !$0.isEmpty && $0.allSatisfy(\.isNumber) && Int($0).map { (0...255).contains($0) } == true
        }) else { return nil }
        if let user, user.range(of: #"^[a-zA-Z0-9_][a-zA-Z0-9_.-]*$"#, options: .regularExpression) == nil {
            return nil
        }
        var components = URLComponents()
        components.scheme = "ssh"
        components.host = host
        components.user = user
        return components.url
    }

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
