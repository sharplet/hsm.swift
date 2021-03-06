import class Foundation.Bundle
import XCTest

// swiftlint:disable:next type_name
final class hsmTests: XCTestCase {
  var temporaryDirectory: URL!

  override func setUpWithError() throws {
    try super.setUpWithError()
    continueAfterFailure = false
    temporaryDirectory = try createTemporaryDirectory(withTemplate: "hsmTests-XXXXXX")
  }

  override func tearDownWithError() throws {
    try FileManager.default.removeItem(at: temporaryDirectory)
    try super.tearDownWithError()
  }

  func testHackAssembler() throws {
    let foo = temporaryDirectory.appendingPathComponent("foo.asm", isDirectory: false)
    let fooOutput = foo.deletingPathExtension().appendingPathExtension("hack")
    try Data("@-1\nD=M\n".utf8).write(to: foo)
    let bar = temporaryDirectory.appendingPathComponent("bar.asm", isDirectory: false)
    let barOutput = bar.deletingPathExtension().appendingPathExtension("hack")
    try Data("@bar\nA=D+1\n".utf8).write(to: bar)

    let pipe = Pipe()
    let process = Process()
    process.executableURL = productsDirectory.appendingPathComponent("hsm")
    process.arguments = [foo.path, bar.path]
    process.standardError = pipe
    process.standardOutput = pipe
    try process.run()
    process.waitUntilExit()

    let output = try pipe.fileHandleForReading.readToEnd().flatMap { data in
      String(data: data, encoding: .utf8)
    } ?? ""

    XCTAssertEqual(output, "")
    XCTAssertEqual(try String(contentsOf: fooOutput), "0111111111111111\n1111110000010000\n")
    XCTAssertEqual(try String(contentsOf: barOutput), "0000000000010000\n1110011111100000\n")
  }

  var productsDirectory: URL {
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
  }
}
