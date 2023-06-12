import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SwiftECSPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
//        ComponentMacro.self,
        //        BufferedMacro.self,
    ]
}
