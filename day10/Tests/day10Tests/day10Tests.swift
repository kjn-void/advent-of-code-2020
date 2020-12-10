import XCTest
import class Foundation.Bundle

final class day10Tests: XCTestCase {
    func test1() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let day10Binary = productsDirectory.appendingPathComponent("day10")

        let process = Process()
        process.executableURL = day10Binary
        process.arguments = [ "test1" ]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertTrue(output!.contains("Part 1 : 35"))
        XCTAssertTrue(output!.contains("Part 2 : 8"))
    }

    func test2() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let day10Binary = productsDirectory.appendingPathComponent("day10")

        let process = Process()
        process.executableURL = day10Binary
        process.arguments = [ "test2" ]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertTrue(output!.contains("Part 1 : 220"))
        XCTAssertTrue(output!.contains("Part 2 : 19208"))
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("test1", test1),
        ("test2", test2),
    ]
}
