import Foundation
import Observation

@Observable
final class FileCollection {
    private(set) var files: [URL] = []
    private var fileSet: Set<URL> = []

    var count: Int { files.count }
    var isEmpty: Bool { files.isEmpty }

    func add(urls: [URL]) {
        for url in urls {
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            let (inserted, _) = fileSet.insert(url)
            if inserted {
                files.append(url)
            }
        }
    }

    func remove(at index: Int) {
        guard index < files.count else { return }
        let url = files.remove(at: index)
        fileSet.remove(url)
    }

    func remove(urls: [URL]) {
        let urlSet = Set(urls)
        fileSet.subtract(urlSet)
        files.removeAll { urlSet.contains($0) }
    }

    func removeAll() {
        files.removeAll()
        fileSet.removeAll()
    }

    func contains(_ url: URL) -> Bool {
        fileSet.contains(url)
    }
}
