import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MemoryPool
import MemoryPoolMacros
import SwiftSyntax
import SwiftBasicFormat
import SwiftDiagnostics
import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacros


final class BufferedMacroTests: XCTestCase {

    let macros: [String: Macro.Type] = [
        "MemoryPooled": MemoryPooledMacro.self,
    ]

    func testMacro() {
        let source = """
            @MemoryPooled
            struct Foo {
                var x: Int?
            }
            """
        let expectedSource = """
            
            struct Foo {
                var x: Int? {
                    get {
                        fatalError()
                    }
                    set {
                        fatalError()
                    }
                struct Storage {
                    var x: Int?
                }
                var accessor: MemoryPoolAccessor<Self>
            }
            """
        assertMacroExpansion(source, expandedSource: expectedSource, macros: macros)
    }
}

