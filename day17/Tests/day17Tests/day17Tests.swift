import XCTest
import class Foundation.Bundle

final class day17Tests: XCTestCase {
    func test1() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.15, *) else {
            return
        }

        let day17Binary = productsDirectory.appendingPathComponent("day17")

        let process = Process()
        process.executableURL = day17Binary
        process.arguments = [ "test" ]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertTrue(output!.contains("Part 1 : 112"))
        XCTAssertTrue(output!.contains("Part 2 : 848"))
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
    ]
}
