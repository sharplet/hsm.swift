import Hack
import XCTest

final class ParserTests: XCTestCase {
  var parser: Parser!

  override func setUp() {
    super.setUp()
    parser = Parser()
  }

  override func tearDown() {
    parser = nil
    super.tearDown()
  }

  func testItIgnoresEmptyLines() throws {
    try parser.parse("")
    XCTAssertEqual(parser.instructions, [])
  }

  func testItIgnoresWhitespaceOnlyLines() throws {
    try parser.parse("\t ")
    XCTAssertEqual(parser.instructions, [])
  }

  func testItParsesAInstructions() throws {
    try parser.parse(" @1")
    try parser.parse("@456")
    try parser.parse("@foo")
    try parser.parse("@foo//bar")
    try parser.parse("@-1")
    XCTAssertEqual(parser.instructions, [
      .aliteral(1),
      .aliteral(456),
      .asymbol("foo"),
      .asymbol("foo"),
      .aliteral(-1),
    ])
  }
}
