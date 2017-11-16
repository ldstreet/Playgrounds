//: Playground - noun: a place where people can play

import UIKit

public struct OrderedSet<T: Hashable>: IteratorProtocol, Sequence, ExpressibleByArrayLiteral {
    
    //MARK: - IteratorProtocol
    public typealias Element = T
    
    private var _count = 0
    public mutating func next() -> Element? {
        guard _count < internalArray.count else { return nil }
        
        defer { _count += 1 }
        
        return internalArray[_count]
    }
    
    
    //MARK: - Properties
    private var internalArray = [Element]()
    private var hashToIndexMap = [Int: Int]()
    private var count: Int {
        return internalArray.count
    }
    
    public init() { }
    
    public init(arrayLiteral elements: Element...) {
        internalArray = Array(elements)
        for elem in elements.enumerated() {
            hashToIndexMap[elem.element.hashValue] = elem.offset
        }
    }
    
    public mutating func append(_ element: Element) {
        internalArray.append(element)
        hashToIndexMap[element.hashValue] = internalArray.count - 1
    }
    
    public mutating func remove(_ element: Element) {
        guard let index = hashToIndexMap[element.hashValue] else {
            print("OrderedSet does not contain element \(element))")
            return
        }
        internalArray.remove(at: index)
        hashToIndexMap.removeValue(forKey: element.hashValue)
    }
    
    public func contains(_ element: Element) -> Bool {
        return hashToIndexMap[element.hashValue] != nil
    }
    
}


let oset: OrderedSet<String> = ["hello", "world", "its", "me"]

for elem in oset {
    print(elem)
}

oset.forEach { elem in
    print(elem)
}

oset.contains("its")
oset.contains("nothing")

let mappedOset = oset.map { elem in
    return elem + "!"
}

mappedOset.forEach { elem in
    print(elem)
}

mappedOset.contains("hello!")
