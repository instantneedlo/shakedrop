import XCTest
@testable import ShakeDrop

final class FileCollectionTests: XCTestCase {
    var collection: FileCollection!
    var tempDir: URL!

    override func setUp() {
        collection = FileCollection()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ShakeDropTests-\(UUID().uuidString)")
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        collection = nil
        tempDir = nil
    }

    func makeTempFile(name: String) -> URL {
        let url = tempDir.appendingPathComponent(name)
        FileManager.default.createFile(atPath: url.path, contents: Data())
        return url
    }

    // MARK: - Add

    func testAddSingleFile() {
        let file = makeTempFile(name: "test.txt")
        collection.add(urls: [file])
        XCTAssertEqual(collection.count, 1)
    }

    func testAddMultipleFiles() {
        let a = makeTempFile(name: "a.txt")
        let b = makeTempFile(name: "b.txt")
        collection.add(urls: [a, b])
        XCTAssertEqual(collection.count, 2)
    }

    func testAddDuplicateURLs() {
        let file = makeTempFile(name: "dup.txt")
        collection.add(urls: [file])
        collection.add(urls: [file])
        XCTAssertEqual(collection.count, 1)
    }

    func testAddNonExistentFileSkipped() {
        let fake = tempDir.appendingPathComponent("ghost.txt")
        collection.add(urls: [fake])
        XCTAssertEqual(collection.count, 0)
    }

    // MARK: - Remove

    func testRemoveAtIndex() {
        let a = makeTempFile(name: "a.txt")
        let b = makeTempFile(name: "b.txt")
        collection.add(urls: [a, b])
        collection.remove(at: 0)
        XCTAssertEqual(collection.count, 1)
        XCTAssertTrue(collection.files.contains(b))
    }

    func testRemoveByURLs() {
        let a = makeTempFile(name: "a.txt")
        let b = makeTempFile(name: "b.txt")
        collection.add(urls: [a, b])
        collection.remove(urls: [a])
        XCTAssertEqual(collection.count, 1)
        XCTAssertTrue(collection.files.contains(b))
    }

    func testRemoveAll() {
        collection.add(urls: [
            makeTempFile(name: "a.txt"),
            makeTempFile(name: "b.txt")
        ])
        collection.removeAll()
        XCTAssertEqual(collection.count, 0)
        XCTAssertTrue(collection.isEmpty)
    }

    // MARK: - Contains

    func testContains() {
        let file = makeTempFile(name: "x.txt")
        collection.add(urls: [file])
        XCTAssertTrue(collection.contains(file))
    }

    func testDoesNotContain() {
        let fake = tempDir.appendingPathComponent("nope.txt")
        XCTAssertFalse(collection.contains(fake))
    }
}
