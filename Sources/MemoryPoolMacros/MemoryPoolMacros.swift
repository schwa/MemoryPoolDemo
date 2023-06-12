import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import os

let logger = Logger(subsystem: "MemoryPoolMacros", category: "MemoryPoolMacros")

@main
struct SwiftECSPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MemoryPooledMacro.self,
    ]
}

public struct MemoryPooledMacro {
}

extension MemoryPooledMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        logger.debug("\(type(of:self), privacy: .public), MemberMacro, \(#function, privacy: .public)")

        let memberVariables = declaration.memberBlock.members.compactMap {
            $0.decl.as(VariableDeclSyntax.self)?.as(DeclSyntax.self)
        }

        return [
            "struct Storage {",
        ]
        + memberVariables + [
            "}",
            "var accessor: MemoryPoolAccessor<Self>",
        ]
    }
}

extension MemoryPooledMacro: ConformanceMacro {
    public static func expansion(of node: AttributeSyntax, providingConformancesOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        logger.debug("\(type(of:self), privacy: .public), ConformanceMacro, \(#function, privacy: .public)")
        return [("MemoryPooledProtocol", nil)]
    }
}

extension MemoryPooledMacro: MemberAttributeMacro {
    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingAttributesFor member: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AttributeSyntax] {
        logger.debug("\(type(of:self), privacy: .public), MemberAttributeMacro, \(#function, privacy: .public)")
        if let variable = member.as(VariableDeclSyntax.self) {
            print("#############################################################################################################")
            print(declaration.route)
            print(member.route)
            print(declaration)
            print("###########")
            return ["@MemoryPooled"]
        }
        else {
            return []
        }
    }
}

extension MemoryPooledMacro: AccessorMacro {
    public static func expansion(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
        logger.debug("\(type(of:self), privacy: .public), AccessorMacro, \(#function, privacy: .public)")
        return ["""
        get {
            fatalError()
        }
        set {
            fatalError()
        }
        """]
    }
}

// MARK: -

extension SyntaxProtocol {
    /// Get an array of all of this node's ancestors or an empty array if this node has no parent (awww, sad)
    var ancestors: [SyntaxProtocol] {
        guard let parent else {
            return []
        }
        return parent.ancestors + [parent]
    }

    var depth: Int {
        return ancestors.count
    }

    var ancestorNames: [String?] {
        return ancestors.map { $0.simpleName }
    }

    var ancestorTypes: [SyntaxProtocol.Type] {
        return ancestors.map { $0.syntaxNodeType }
    }

    /// Get's the closest ancestor that is a Swift Decl 'container'.
    var closestAncestorContainer: DeclSyntax? {
        guard let parent else {
            return nil
        }
        if let structDecl = parent.as(StructDeclSyntax.self) {
            return structDecl.as(DeclSyntax.self)
        }
        // TODO: Sprinkle in more types here
        else {
            return parent.closestAncestorContainer
        }
    }

    // Attempts to get the "simple" name of a syntax node
    var simpleName: String? {
        if let variable = self.as(VariableDeclSyntax.self) {
            return variable.bindings.first?.pattern.trimmedDescription
        }
        if let structDecl = self.as(StructDeclSyntax.self) {
            return structDecl.identifier.trimmedDescription
        }
        // TODO: add more named types here
        else {
            return nil
        }
    }

    private var routeItem: String {
        if let simpleName {
            return "\(syntaxNodeType)(\"\(simpleName)\")"
        }
        else {
            return "\(syntaxNodeType)()"
        }
    }

    var route: String {
        return (ancestors.map { $0.routeItem } + [routeItem]).joined(separator: "/")
    }
}
