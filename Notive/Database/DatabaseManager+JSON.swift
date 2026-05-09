import Foundation

// MARK: - JSON helpers used by DatabaseManager extensions

extension DatabaseManager {

    func encodeJSON<T: Encodable>(_ value: T) -> String {
        guard
            let data = try? JSONEncoder().encode(value),
            let str  = String(data: data, encoding: .utf8)
        else { return "[]" }
        return str
    }

    func decodeJSON<T: Decodable>(_ type: T.Type, from string: String) -> T where T: ExpressibleByArrayLiteral {
        guard
            let data  = string.data(using: .utf8),
            let value = try? JSONDecoder().decode(type, from: data)
        else { return [] }
        return value
    }
}
