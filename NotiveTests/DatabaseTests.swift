import XCTest
@testable import Notive

final class DatabaseTests: XCTestCase {
    var manager: DatabaseManager!
    var notes: NoteRepository!
    var folders: FolderRepository!
    var tags: TagRepository!

    override func setUp() async throws {
        try await super.setUp()
        manager = DatabaseManager.makeForTesting()
        try await manager.setUp()
        notes   = NoteRepository(manager: manager)
        folders = FolderRepository(manager: manager)
        tags    = TagRepository(manager: manager)
    }

    // MARK: - Insert + fetch by ID

    func testInsertAndFetchById() async throws {
        let note = Note(title: "Hello", body: "World", tags: ["swift"])
        try await notes.insert(note)

        let fetched = try await notes.fetch(id: note.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, note.id)
        XCTAssertEqual(fetched?.title, "Hello")
        XCTAssertEqual(fetched?.body, "World")
        XCTAssertEqual(fetched?.tags, ["swift"])
    }

    // MARK: - Update

    func testUpdateTitle() async throws {
        var note = Note(title: "Original")
        try await notes.insert(note)

        note.title = "Updated"
        note.updatedAt = Date()
        try await notes.update(note)

        let fetched = try await notes.fetch(id: note.id)
        XCTAssertEqual(fetched?.title, "Updated")
    }

    // MARK: - Delete

    func testDelete() async throws {
        let a = Note(title: "A")
        let b = Note(title: "B")
        try await notes.insert(a)
        try await notes.insert(b)

        let countBefore = try await notes.count()
        XCTAssertEqual(countBefore, 2)

        try await notes.delete(id: a.id)
        let countAfter = try await notes.count()
        XCTAssertEqual(countAfter, 1)
    }

    // MARK: - Fetch by folder

    func testFetchByFolderID() async throws {
        let folder = Folder(name: "Work")
        try await folders.insert(folder)

        let n1 = Note(title: "1", folderID: folder.id)
        let n2 = Note(title: "2", folderID: folder.id)
        let n3 = Note(title: "3", folderID: folder.id)
        let n4 = Note(title: "Outside")

        try await notes.insert(n1)
        try await notes.insert(n2)
        try await notes.insert(n3)
        try await notes.insert(n4)

        let inFolder = try await notes.fetch(folderID: folder.id)
        XCTAssertEqual(inFolder.count, 3)
    }

    // MARK: - Tags round-trip

    func testTagsRoundTrip() async throws {
        let note = Note(title: "Tagged", tags: ["swift", "ai"])
        try await notes.insert(note)

        let fetched = try await notes.fetch(id: note.id)
        XCTAssertEqual(Set(fetched?.tags ?? []), Set(["swift", "ai"]))
    }
}
