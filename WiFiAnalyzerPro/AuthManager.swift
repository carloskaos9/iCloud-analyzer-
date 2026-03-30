import Foundation
import Combine

// MARK: - Models

struct ClientInfo: Codable {
    let name: String
    let plan: String
}

struct ValidateTokenResponse: Codable {
    let valid: Bool
    let client: ClientInfo?
}

struct SpeedTestPayload: Codable {
    let accessToken: String
    let downloadSpeed: Double?
    let uploadSpeed: Double?
    let latency: Double?
    let connectionType: String?
    let networkGeneration: String?
    let publicIp: String?
    let city: String?
    let country: String?
    let deviceInfo: String?
}

// MARK: - AuthManager

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    // Replace with your actual deployed URL
    private let baseURL = "https://wifianalys-7srikbkl.manus.space"
    private let tokenKey = "wifi_analyzer_access_token"

    @Published var isAuthenticated = false
    @Published var clientName: String = ""
    @Published var clientPlan: String = ""
    @Published var isValidating = false
    @Published var errorMessage: String?

    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    init() {
        // Auto-validate saved token on startup
        if let token = accessToken, !token.isEmpty {
            Task { await validateToken(token) }
        }
    }

    func validateToken(_ token: String) async {
        isValidating = true
        errorMessage = nil

        do {
            let url = URL(string: "\(baseURL)/api/trpc/speedTest.validateToken?input=%7B%22json%22%3A%7B%22accessToken%22%3A%22\(token)%22%7D%7D")!
            var request = URLRequest(url: url)
            request.timeoutInterval = 10

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            // tRPC response format: {"result":{"data":{"json":{...}}}}
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let result = json["result"] as? [String: Any],
               let dataObj = result["data"] as? [String: Any],
               let jsonObj = dataObj["json"] as? [String: Any],
               let valid = jsonObj["valid"] as? Bool {

                if valid {
                    self.accessToken = token
                    self.isAuthenticated = true
                    if let clientObj = jsonObj["client"] as? [String: Any] {
                        self.clientName = clientObj["name"] as? String ?? ""
                        self.clientPlan = clientObj["plan"] as? String ?? "free"
                    }
                } else {
                    self.isAuthenticated = false
                    self.accessToken = nil
                    self.errorMessage = "Token inválido ou conta inativa"
                }
            }
        } catch {
            self.errorMessage = "Erro de conexão: \(error.localizedDescription)"
        }

        isValidating = false
    }

    func logout() {
        accessToken = nil
        isAuthenticated = false
        clientName = ""
        clientPlan = ""
    }

    func saveSpeedTestSession(
        downloadSpeed: Double?,
        uploadSpeed: Double?,
        latency: Double?,
        connectionType: String?,
        networkGeneration: String?,
        publicIp: String?,
        city: String?,
        country: String?,
        deviceInfo: String?
    ) async {
        guard let token = accessToken else { return }

        let payload = SpeedTestPayload(
            accessToken: token,
            downloadSpeed: downloadSpeed,
            uploadSpeed: uploadSpeed,
            latency: latency,
            connectionType: connectionType,
            networkGeneration: networkGeneration,
            publicIp: publicIp,
            city: city,
            country: country,
            deviceInfo: deviceInfo
        )

        do {
            let url = URL(string: "\(baseURL)/api/trpc/speedTest.saveSession")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            // tRPC POST format
            let body: [String: Any] = ["json": try JSONSerialization.jsonObject(with: JSONEncoder().encode(payload))]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("[AuthManager] Session saved: HTTP \(httpResponse.statusCode)")
            }
        } catch {
            print("[AuthManager] Failed to save session: \(error)")
        }
    }
}
