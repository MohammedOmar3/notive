import Foundation
import SQLite

// MARK: - Errors

enum DatabaseError: Error, LocalizedError {
    case notInitialized
    case notFound
    case mappingFailed(String)

    var errorDescription: String? {
        switch self {
        case .notInitialized:   return "Database has not been set up yet."
        case .notFound:         return "The requested record was not found."
        case .mappingFailed(let detail): return "Failed to map database row: \(detail)"
        }
    }
}

// MARK: - DatabaseManager

actor DatabaseManager {

    // MARK: Singleton

    static let shared = DatabaseManager()

    // MARK: State

    private var db: Connection?

    // MARK: Init

    private init() {}

    /// Creates a separate DatabaseManager using an in-memory database.
    /// Used exclusively in unit tests for isolation.
    static func makeForTesting() -> DatabaseManager {
        DatabaseManager(path: ":memory:")
    }

    private init(path: String) {
        // In-memory init — used by makeForTesting()
        // setUp(path:) must still be called before use.
        self._testPath = path
    }

    private var _testPath: String? = nil

    // MARK: Setup

    /// Opens the SQLite database and runs all pending migrations.
    /// Must be called once at app launch before any repository is used.
    func setUp() throws {
        let path: String
        if let testPath = _testPath {
            path = testPath
        } else {
            let dir = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            path = dir.appendingPathComponent("notive.sqlite").path
        }
        let connection = try Connection(path)
        try Migration.run(on: connection)
        self.db = connection
        NovLogger.info("Database opened at: \(path)")
    }

    // MARK: Internal helpers (used by extensions)

    func connection() throws -> Connection {
        guard let db else { throw DatabaseError.notInitialized }
        return db
    }
}
