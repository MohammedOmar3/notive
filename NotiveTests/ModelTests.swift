import XCTest
@testable import Notive

final class ModelTests: XCTestCase {

    // MARK: - Note

    func testPreviewRetainsMarkdown() {
        let note = Note(body: "Hello **world**")
        XCTAssertEqual(note.preview, "Hello **world**")
    }

    func testWordCount() {
        let words = Array(repeating: "word", count: 50).joined(separator: " ")
        let note = Note(body: words)
        XCTAssertEqual(note.wordCount, 50)
    }

    func testWordCountEmptyBody() {
        let note = Note(body: "")
        XCTAssertEqual(note.wordCount, 0)
    }

    func testPreviewTruncatesAt120() {
        let longBody = String(repeating: "a", count: 200)
        let note = Note(body: longBody)
        XCTAssertEqual(note.preview.count, 120)
    }

    func testMakeEmpty() {
        let note = Note.makeEmpty()
        XCTAssertTrue(note.title.isEmpty)
        XCTAssertTrue(note.body.isEmpty)
        XCTAssertFalse(note.isPinned)
        XCTAssertNil(note.folderID)
        XCTAssertTrue(note.tags.isEmpty)
    }

    // MARK: - VoiceNote state

    func testVoiceNoteStateMutation() {
        var vn = VoiceNote.makeEmpty()
        XCTAssertEqual(vn.processingState, .idle)
        vn.processingState = .complete
        XCTAssertEqual(vn.processingState, .complete)
    }

    // MARK: - Folder equatable

    func testFolderEquatableWithCopy() {
        let folder = Folder(name: "Work")
        let copy = folder
        XCTAssertEqual(folder, copy)
    }
}
