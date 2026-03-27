import Foundation

enum UserDefaultsStore {
    private static let configKey = "lastSessionConfig"

    static func save(_ config: SessionConfig) {
        guard let data = try? JSONEncoder().encode(config) else { return }
        UserDefaults.standard.set(data, forKey: configKey)
    }

    static func load() -> SessionConfig {
        guard let data = UserDefaults.standard.data(forKey: configKey),
              let config = try? JSONDecoder().decode(SessionConfig.self, from: data)
        else {
            return .default
        }
        return config
    }
}
