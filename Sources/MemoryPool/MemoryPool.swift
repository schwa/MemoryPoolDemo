public struct MemoryPool <Element> {
    public typealias Elements = [Element?]
    public typealias Index = Elements.Index

    var elements: Elements
    var freeList = Set<Index>()

    public init(capacity: Int) {
        elements = Array(repeatElement(nil, count: capacity))
        freeList = Set(0..<capacity)
    }

    public mutating func allocate() -> Index {
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

    public mutating func free(index: Index) {
        assert(!freeList.contains(index))
        freeList.insert(index)
    }
}

public protocol MemoryPooled {
    associatedtype Storage
    var index: MemoryPool<Storage>.Index { get set }
}

