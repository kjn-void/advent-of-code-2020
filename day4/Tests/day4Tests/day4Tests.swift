import XCTest
import class Foundation.Bundle

final class day4Tests: XCTestCase {
    func testExample() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let day4Binary = productsDirectory.appendingPathComponent("day4")

        let process = Process()
        process.executableURL = day4Binary
        process.arguments = [ "test" ]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, """
                                 🌟 Part 1 : 2
                                 🌟 Part 2 : 2

                                 """)
    }

    func testValid() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let day4Binary = productsDirectory.appendingPathComponent("day4")

        let process = Process()
        process.executableURL = day4Binary
        process.arguments = [ "valid" ]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, """
                                 🌟 Part 1 : 4
                                 🌟 Part 2 : 4

                                 """)
    }

    func testInvalid() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let day4Binary = productsDirectory.appendingPathComponent("day4")

        let process = Process()
        process.executableURL = day4Binary
        process.arguments = [ "invalid" ]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, """
                                 🌟 Part 1 : 4
                                 🌟 Part 2 : 0

                                 """)
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
        ("testPart1", testExample),
        ("testPart2Valid", testValid),
        ("testPart2Invalid", testInvalid),
    ]
}
