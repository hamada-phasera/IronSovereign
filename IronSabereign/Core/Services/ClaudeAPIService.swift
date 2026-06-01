import Foundation

struct ClaudeRequest: Codable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [Message]

    struct Message: Codable {
        let role: String
        let content: String
    }

    enum CodingKeys: String, CodingKey {
        case model, messages, system
        case maxTokens = "max_tokens"
    }
}

struct ClaudeResponse: Codable {
    let content: [ContentBlock]

    struct ContentBlock: Codable {
        let type: String
        let text: String?
    }
}

enum ClaudeAPIError: Error {
    case noAPIKey
    case networkError(Error)
    case invalidResponse
    case parseError
}

class ClaudeAPIService {
    static let shared = ClaudeAPIService()
    private let baseURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-20250514"

    private var apiKey: String? {
        // Keychain から取得（開発中はUserDefaultsで代替）
        UserDefaults.standard.string(forKey: "claude_api_key")
    }

    func setAPIKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "claude_api_key")
    }

    var isConfigured: Bool { apiKey != nil && !(apiKey?.isEmpty ?? true) }

    func generateOptimizedPlan(prompt: String) async throws -> String {
        guard let key = apiKey, !key.isEmpty else {
            throw ClaudeAPIError.noAPIKey
        }

        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body = ClaudeRequest(
            model: model,
            maxTokens: 4096,
            system: "あなたはNSCA-CSCS認定のS&Cコーチです。JSON形式のみで応答してください。",
            messages: [.init(role: "user", content: prompt)]
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ClaudeAPIError.invalidResponse
            }
            let decoded = try JSONDecoder().decode(ClaudeResponse.self, from: data)
            return decoded.content.first?.text ?? ""
        } catch let error as ClaudeAPIError {
            throw error
        } catch {
            throw ClaudeAPIError.networkError(error)
        }
    }
}
