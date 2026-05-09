import Foundation
import OSLog

// MARK: - NovLogger
// Thin wrapper around os.Logger.
// Never log user note content — log structure and errors only.

enum NovLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.notive.app"

    private static let general  = Logger(subsystem: subsystem, category: "general")
    private static let database = Logger(subsystem: subsystem, category: "database")
    private static let ai       = Logger(subsystem: subsystem, category: "ai")
    private static let ui       = Logger(subsystem: subsystem, category: "ui")

    static func info(_ message: String, category: LogCategory = .general) {
        logger(for: category).info("\(message, privacy: .public)")
    }

    static func debug(_ message: String, category: LogCategory = .general) {
        logger(for: category).debug("\(message, privacy: .public)")
    }

    static func error(_ message: String, category: LogCategory = .general) {
        logger(for: category).error("\(message, privacy: .public)")
    }

    static func fault(_ message: String, category: LogCategory = .general) {
        logger(for: category).fault("\(message, privacy: .public)")
    }

    // MARK: - Private

    private static func logger(for category: LogCategory) -> Logger {
        switch category {
        case .general:  return general
        case .database: return database
        case .ai:       return ai
        case .ui:       return ui
        }
    }
}

enum LogCategory {
    case general, database, ai, ui
}
