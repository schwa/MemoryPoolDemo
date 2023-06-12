public class MemoryPool <Element> where Element: MemoryPooledProtocol {
    public typealias Elements = [Element.Storage?]
    public typealias Index = Elements.Index

    var elements: Elements
    var freeList = Set<Index>()

    public init(capacity: Int) {
        elements = Array(repeatElement(nil, count: capacity))
        freeList = Set(0..<capacity)
    }

    internal func allocate() -> Index {
        if let index = freeList.popFirst() {
            return index
        }
        else {
            if elements.count == 0 {
                assert(freeList.isEmpty)
                elements = Array(repeatElement(nil, count: 16))
                freeList = Set(0..<16)
            }
            else {
                let count = elements.count
                elements = elements + repeatElement(nil, count: count)
                freeList.formUnion(Set(count..<(count * 2)))
            }
            guard let index = freeList.popFirst() else {
                fatalError()
            }
            return index
        }
    }

    internal func free(index: Index) {
        assert(!freeList.contains(index))
        freeList.insert(index)
    }
}

public protocol MemoryPooledProtocol {
    associatedtype Storage
    var accessor: MemoryPoolAccessor<Self> { get set }
}

public struct MemoryPoolAccessor <Element> where Element: MemoryPooledProtocol {
    public var pool: MemoryPool<Element>
    public var index: MemoryPool<Element>.Index
}

@attached(accessor)
@attached(conformance)
@attached(member, names: named(accessor), named(Storage))
@attached(memberAttribute)
public macro MemoryPooled() = #externalMacro(module: "MemoryPoolMacros", type: "MemoryPooledMacro")
