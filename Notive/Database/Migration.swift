import Foundation
import SQLite

enum Migration {

    // MARK: - Entry point

    static func run(on db: Connection) throws {
        let current = userVersion(of: db)
        NovLogger.info("Database schema version: \(current)")

        if current < 1 {
            try migrateV1(on: db)
            setUserVersion(1, on: db)
            NovLogger.info("Migrated to schema v1")
        }
        // Add future migrations here:
        // if current < 2 { try migrateV2(on: db); setUserVersion(2, on: db) }
    }

    // MARK: - V1: initial schema

    private static func migrateV1(on db: Connection) throws {
        try db.execute("""
            CREATE TABLE IF NOT EXISTS notes (
                id           TEXT    PRIMARY KEY NOT NULL,
                title        TEXT    NOT NULL DEFAULT '',
                body         TEXT    NOT NULL DEFAULT '',
                created_at   REAL    NOT NULL,
                updated_at   REAL    NOT NULL,
                folder_id    TEXT,
                tags         TEXT    NOT NULL DEFAULT '[]',
                is_pinned    INTEGER NOT NULL DEFAULT 0,
                indexed_at   REAL,
                embedding    BLOB
            );
        """)

        try db.execute("""
            CREATE TABLE IF NOT EXISTS folders (
                id           TEXT    PRIMARY KEY NOT NULL,
                name         TEXT    NOT NULL,
                created_at   REAL    NOT NULL,
                color        TEXT    NOT NULL DEFAULT '#6B6BFF'
            );
        """)

        try db.execute("""
            CREATE TABLE IF NOT EXISTS tags (
                id           TEXT    PRIMARY KEY NOT NULL,
                name         TEXT    NOT NULL UNIQUE,
                created_at   REAL    NOT NULL
            );
        """)

        try db.execute("""
            CREATE TABLE IF NOT EXISTS voice_notes (
                id               TEXT    PRIMARY KEY NOT NULL,
                title            TEXT    NOT NULL DEFAULT '',
                audio_file_path  TEXT    NOT NULL,
                transcript       TEXT,
                summary          TEXT,
                key_points       TEXT    NOT NULL DEFAULT '[]',
                duration         REAL    NOT NULL DEFAULT 0,
                created_at       REAL    NOT NULL,
                linked_note_id   TEXT,
                processing_state TEXT    NOT NULL DEFAULT 'idle'
            );
        """)
    }

    // MARK: - user_version helpers

    private static func userVersion(of db: Connection) -> Int {
        (try? db.scalar("PRAGMA user_version") as? Int64).map(Int.init) ?? 0
    }

    private static func setUserVersion(_ version: Int, on db: Connection) {
        // PRAGMA user_version does not support bound parameters; version is an Int literal.
        _ = try? db.execute("PRAGMA user_version = \(version)")
    }
}
