import Foundation
import MemoryPool

@MemoryPooled
struct Bird {
    var name: String
}

@main
struct Demo {
    static func main() async throws {

//        var pool = MemoryPool<Bird>(capacity: 1)
        print("main")
    }
}


