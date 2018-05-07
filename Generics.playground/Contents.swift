

import UIKit

//:## 0) First some boiler plate

internal enum ExampleError: Error {
    case emptyString
    case noMatch
    case wrongType
}

//:## 1) Generic Result Type

/*:
 Many times, when a developer wants to write an asyncronous function, they will use closures like this:
 
 ````
 internal func fetchStringAsyncWithNormalClosure(arg: String, completion: (String?, Error?) -> Void) {
    if arg.isEmpty {
        completion(nil, ExampleError.emptyString)
    } else {
        completion(arg, nil)
    }
 }
 ````
 
 But this has a few issues:
 1. Verbosity - ```` (String?, Error?) -> Void) ```` is both ugly and long
 2. Developer Error - Because String and Error are both optional, one could actually include both or neither in the result. i.e.
 
 ````
    completion(nil, nil)
    completion("Result", .someError)
 ````
 
 3. Or, the consumer could forget to check one or the other. i.e.
 
 ````
 fetchStringAsyncWithNormalClosure(arg: "someString") { str, error in
    guard let s = str else { return }
 }
 ````
 
 Really, our completion result should be exclusive. Either the result was successful, or there was an error. Most of the time there is no middle ground. So, lets model that in an enum.
 
````
 public enum Result {
    case success(String)
    case error(Error)
 }
 ````
 
 But there is one problem here...what if we want this result to be an Int? Or a Bool? Or really any other type? Here is where generics come in...Instead of tying this enum down to just a single type, we can simply use generic type T. Like this:
 
*/

public enum Result<T> {
    case success(T)
    case error(Error)
}

/*:
 Now, Result can take be defined as any type T at compile time. Here is what our fetch function can look like now:
 ````
 internal func fetchStringAsyncWithResultClosure(arg: String, completion: (Result<String>) -> Void) {
    if arg.isEmpty {
        completion(.error(ExampleError.emptyString))
    } else {
        completion(.success(arg))
    }
 }
 ````
 
 This is looking better already. Shorter syntax, no optionals, and exclusive results. The best part is we are applying to DRY principle by not repeating our Result enum for each type we might want to use it with. We simply write once and reuse. But...we can take this one step further with the help of generics and typealias. Though ````(Result<String>) -> Void)```` is certiainly better than ````(String?, Error?) -> Void```` what if we could could get a little more concise and take out the ugliness of closure syntax? This is definitely a job for typealiases, but did you know that they can be generic as well?
 */

public typealias ResultClosure<T> = (Result<T>) -> Void

/*:
 Now we can simply write our fetch function like this:
 */

internal func fetchStringAsync(arg: String, completion: ResultClosure<String>) {
    if arg.isEmpty {
        completion(.error(ExampleError.emptyString))
    } else {
        completion(.success(arg))
    }
}

//: Nice! And we can now call it like this:

fetchStringAsync(arg: "someString") { result in
    switch result {
    case .success(let str):
        print(str)
    case .error(let error):
        print(error)
    }
}

fetchStringAsync(arg: "") { result in
    switch result {
    case .success(let str):
        print(str)
    case .error(let error):
        print(error)
    }
}

//:## 2) Generic Codable extensions

/*:
 Generics don't have to be just used with types. And they also don't have to total wild cards. We can apply generics to functions and constrain them. Let's take an example with Codable. By default if you want to encode and decode json, you have to instantiate an JSONEncoder/JSONDecoder. That is easy enough, but lets simplify through a couple of generic extensions:
 */


extension Data {
    func decodeJson<T: Decodable>(to type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: self)
    }
}

extension Encodable {
    func encodeJson() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

/*:
 Now notice the use of ````<T: Decodable>```` in our decodeJson function. We are defining T as a some to be determined (at compile time) type that will be used within this function signature. But not only that, we are constraining T. You can't just pass in any old type into decodeJson, you must pass in a type that conforms to the protocol Decodable. Now, because we have made that constraint, the compiler can infer that T conforms to Decodable, thus giving us access to all the abilities of a Decodable type. This is why we are able to pass it in successfully to our Decoder. Awesome!
 
 Lets try out our new one-liners:
 */

internal struct SomeStruct: Codable {
    var someString: String
    var someInt: Int
}

let someStruct = SomeStruct(someString: "Hello, World", someInt: 5)
print(someStruct)

do {
    let encodedData = try someStruct.encodeJson()
    let someStructDecoded = try encodedData.decodeJson(to: SomeStruct.self)
    print(someStructDecoded)
} catch { print(error) }

//:## 3) Generic Storage Protocol

/*:
 Let's say our program needs a way to write to disk. For now, we jsut want to use UserDefaults, but we also don't want to be locked into UserDefaults. Having calls to UserDefaults littered throughout your code base is risking painful refactoring later on. Instead, let's abstract into a protocol. That way if in the future we want to swap out our implementation to something like Firebase variables, Coredata, Realm, or some custom mechanism, we can do so easily. We are again going to lean on Codable here to handle any data too complex.
 */

public protocol Storage {
    
    func read<T: Codable>(_ key: String) throws -> T
    
    func write<T: Codable>(_ item: T, at key: String) throws
    
}

/*:
 So here we have to functions, read and write. Similar to our decodeJSON function, both use generics with constraints to ensure that only values that are Codable can be read/written. Now, we can apply this protocol to UserDefaults directly by extending UserDefaults and conforming to Storage:
 */

extension UserDefaults: Storage {
    
    private func userDefaultsCanConsumeWithoutEncoding(_ value: Any) -> Bool {
        return
            (value is Int) ||
            (value is String) ||
            (value is Bool) ||
            (value is Double) ||
            (value is Float) ||
            (value is URL)
    }
    
    public func write<T: Codable>(_ item: T, at key: String) throws {
        let defaults = UserDefaults.standard
        if userDefaultsCanConsumeWithoutEncoding(item) {
            defaults.set(item, forKey: key)
        } else {
            let data = try item.encodeJson()
            defaults.set(data, forKey: key)
        }
        
    }
    
    public func read<T: Codable>(_ key: String) throws -> T {
        guard let value = UserDefaults.standard.value(forKey: key) else { throw ExampleError.noMatch }
        if let basicType = value as? T {
            return basicType
        } else if let data = value as? Data {
            try data.decodeJson(to: T.self)
        }
        throw ExampleError.wrongType
    }
}

/*:
 Great! We can use UserDefaults now without actually referencing UserDefaults. Just make sure to use some form of Dependency Injection when setting your storage variable.
 */

let storage: Storage = UserDefaults.standard

do {
    try storage.write(1.0, at: "One")
    let value: Double = try storage.read("One")
    print(value)
    
    // Read/write works generically! T is inferred by the compiler, so we don't have to worry about any sort of casting or rewriting multiple implementations of the same funcion.
    try storage.write("1.0", at: "One-String")
    let str: String = try storage.read("One-String")
    print(str)
} catch {
    print(error)
}




