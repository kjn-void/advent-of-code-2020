import Foundation

func inputGet() -> [String] {
    let fileName = CommandLine.argc == 1 ? "input" : CommandLine.arguments[1]
    let cwdURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = URL(fileURLWithPath: fileName, relativeTo: cwdURL).appendingPathExtension("txt")
    let content = try! String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    return content.components(separatedBy: "\n").filter { !$0.isEmpty }
}
