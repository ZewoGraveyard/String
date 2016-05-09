// String.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

extension String {
    public static func buffer(size: Int) -> [Int8] {
        return [Int8](repeating: 0, count: size)
    }

    public init?(pointer: UnsafePointer<Int8>, length: Int) {
        var buffer = String.buffer(size: length + 1)
        strncpy(&buffer, pointer, length)

        guard let string = String(validatingUTF8: buffer) else {
            return nil
        }

        self.init(string)
    }

	subscript (i: Int) -> Character? {
		guard i >= 0 && i < characters.count else { return nil }
        return self[index(startIndex, offsetBy: i)]
	}

	subscript (i: Range<Int>) -> String? {
		let verifiedRange = i.clamped(to: 0 ..< characters.count)
		guard i == verifiedRange else { return nil }
		return self[i]
	}

    public func split(separator: Character, maxSplits: Int = .max, omittingEmptySubsequences: Bool = true) -> [String] {
        return characters.split(separator: separator, maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences).map(String.init)
    }

    public func trim() -> String {
        return trim(CharacterSet.whitespaceAndNewline)
    }

    public func trim(_ characters: CharacterSet) -> String {
        return trimLeft(characters).trimRight(characters)
    }

    public func trimLeft(_ characterSet: CharacterSet) -> String {
        var start = 0

        for (index, character) in characters.enumerated() {
            if !characterSet.contains(character: character) {
                start = index
                break
            }
        }

        return self[index(startIndex, offsetBy: start) ..< endIndex]
    }

    public func trimRight(_ characterSet: CharacterSet) -> String {
        var end = 0

        for (index, character) in characters.reversed().enumerated() {
            if !characterSet.contains(character: character) {
                end = index
                break
            }
        }

        return self[startIndex ..< index(endIndex, offsetBy: -end)]
    }

	public func index(of string: String) -> String.CharacterView.Index? {
        return characters.index(of: string.characters)
	}

	public func contains(_ string: String) -> Bool {
        return index(of: string) != nil
	}

	public func split(byString separator: String) -> [String] {
		let separatorChars = separator.characters
        guard var index = characters.index(of: separatorChars) else {
			return [self]
		}
		let separatorCount = separatorChars.count
		var start = characters.startIndex
		var array: [String] = []
		while true {
			let distance = characters.distance(from: characters.startIndex, to: index)
            let offset = distance + characters.distance(from: startIndex, to: start)
            let trange = start ..< characters.index(startIndex, offsetBy: offset)
			array.append(String(characters[trange]))
			start = characters.index(start, offsetBy: distance + separatorCount)
            let substr = characters.suffix(from: start)
            if let _index = substr.index(of: separatorChars) {
				index = _index
			} else {
				break
			}
		}
		array.append(String(characters[start ..< characters.endIndex]))
		return array
	}

	public mutating func replace(string: String, with: String) {
		let strChars = string.characters
		let strCount = strChars.count
		while true {
            guard let index = characters.index(of: strChars) else { break }
			replaceSubrange(index ..< self.index(index, offsetBy: strCount), with: with)
		}
	}
}

extension String.CharacterView {
    func index(of sequence: String.CharacterView) -> String.CharacterView.Index? {
        let seqString = String(sequence)
        for (i, _) in enumerated() {
            // Protect against range overflow errors
            if i + sequence.count > count {
                break
            } else {
                let start = index(startIndex, offsetBy: i)
                let end = index(startIndex, offsetBy: i+sequence.count)
                if String(self[start ..< end]) == seqString {
                    return start
                }
            }
        }
        return nil
    }
}

public enum CharacterSetError: ErrorProtocol {
    case characterIsNotUTF8
}

public struct CharacterSet: ArrayLiteralConvertible {
	public static var whitespaceAndNewline: CharacterSet {
		return [" ", "\t", "\r", "\n"]
	}

	public static var digits: CharacterSet {
		return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	}

    public static var uriQueryAllowed: CharacterSet {
        return ["!", "$", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "=", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "~"]
    }

    public static var uriFragmentAllowed: CharacterSet {
        return ["!", "$", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "=", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "~"]
    }

    public static var uriPathAllowed: CharacterSet {
        return ["!", "$", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", "=", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "~"]
    }

    public static var uriHostAllowed: CharacterSet {
        return ["!", "$", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "=", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "]", "_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "~"]
    }

    public static var uriPasswordAllowed: CharacterSet {
        return ["!", "$", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ";", "=", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "~"]
    }

    public static var uriUserAllowed: CharacterSet {
        return ["!", "$", "&", "\'", "(", ")", "*", "+", ",", "-", ".", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ";", "=", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "_", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "~"]
    }

	private let characters: Set<Character>
	private let isInverted: Bool

	public var inverted: CharacterSet {
		return CharacterSet(characters: characters, inverted: !isInverted)
	}

	public init(characters: Set<Character>, inverted: Bool = false) {
		self.characters = characters
		self.isInverted = inverted
	}

	public init(arrayLiteral elements: Character...) {
		self.init(characters: Set(elements))
	}

	public func contains(character: Character) -> Bool {
		let contains = characters.contains(character)
		return isInverted ? !contains : contains
	}

    public func utf8() throws -> Set<UTF8.CodeUnit> {
        var codeUnits: Set<UTF8.CodeUnit> = []
        for character in characters {
            let utf8 = String(character).utf8
            if utf8.count != 1 {
                throw CharacterSetError.characterIsNotUTF8
            }
            codeUnits.insert(utf8[utf8.startIndex])
        }
        return codeUnits
    }
}

extension String {
    public func starts(with prefix: String) -> Bool {
        return prefix == String(self.characters.prefix(prefix.characters.count))
    }

    public func ends(with suffix: String) -> Bool {
        return suffix == String(self.characters.suffix(suffix.characters.count))
    }

    public var dropLastPathComponent: String {
        let fixedSelf = fixSlashes()

        if fixedSelf == "/" {
            return fixedSelf
        }

        switch fixedSelf.startOfLastPathComponent {

        // relative path, single component
        case fixedSelf.startIndex:
            return ""

        // absolute path, single component
        case fixedSelf.index(after: startIndex):
            return "/"

        // all common cases
        case let startOfLast:
            return String(fixedSelf.characters.prefix(upTo: fixedSelf.index(before: startOfLast)))
        }
    }

    var startOfLastPathComponent: String.CharacterView.Index {
        precondition(!ends(with: "/") && characters.count > 1)

        let characterView = characters
        let startPos = characterView.startIndex
        let endPosition = characterView.endIndex
        var currentPosition = endPosition

        while currentPosition > startPos {
            let previousPosition = characterView.index(before: currentPosition)
            if characterView[previousPosition] == "/" {
                break
            }
            currentPosition = previousPosition
        }

        return currentPosition
    }

    func fixSlashes(compress: Bool = true, stripTrailing: Bool = true) -> String {
        if self == "/" {
            return self
        }

        var result = self

        if compress {
            result.withMutableCharacters { characterView in
                let startPosition = characterView.startIndex
                var endPosition = characterView.endIndex
                var currentPosition = startPosition

                while currentPosition < endPosition {
                    if characterView[currentPosition] == "/" {
                        var afterLastSlashPosition = currentPosition
                        while afterLastSlashPosition < endPosition && characterView[afterLastSlashPosition] == "/" {
                            afterLastSlashPosition = characterView.index(after: afterLastSlashPosition)
                        }
                        if afterLastSlashPosition != characterView.index(after: currentPosition) {
                            characterView.replaceSubrange(currentPosition ..< afterLastSlashPosition, with: ["/"])
                            endPosition = characterView.endIndex
                        }
                        currentPosition = afterLastSlashPosition
                    } else {
                        currentPosition = characterView.index(after: currentPosition)
                    }
                }
            }
        }

        if stripTrailing && result.ends(with: "/") {
            result.remove(at: result.characters.index(before: result.characters.endIndex))
        }

        return result
    }
}

extension String {
    public init(percentEncoded: String) throws {
        struct Error: ErrorProtocol, CustomStringConvertible {
            let description: String
        }

        let spaceCharacter: UInt8 = 32
        let percentCharacter: UInt8 = 37
        let plusCharacter: UInt8 = 43

        var encodedBytes: [UInt8] = [] + percentEncoded.utf8
        var decodedBytes: [UInt8] = []
        var i = 0

        while i < encodedBytes.count {
            let currentCharacter = encodedBytes[i]

            switch currentCharacter {
            case percentCharacter:
                let unicodeA = UnicodeScalar(encodedBytes[i + 1])
                let unicodeB = UnicodeScalar(encodedBytes[i + 2])

                let hexString = "\(unicodeA)\(unicodeB)"

                guard let character = Int(hexString, radix: 16) else {
                    throw Error(description: "Invalid string")
                }

                decodedBytes.append(UInt8(character))
                i += 3

            case plusCharacter:
                decodedBytes.append(spaceCharacter)
                i += 1

            default:
                decodedBytes.append(currentCharacter)
                i += 1
            }
        }

        var string = ""
        var decoder = UTF8()
        var iterator = decodedBytes.makeIterator()
        var finished = false

        while !finished {
            let decodingResult = decoder.decode(&iterator)
            switch decodingResult {
            case .scalarValue(let char): string.append(char)
            case .emptyInput: finished = true
            case .error:
                throw Error(description: "UTF-8 decoding failed")
            }
        }

        self.init(string)
    }
}

extension String {
    public func percentEncoded(allowing allowed: CharacterSet) throws -> String {
        var string = ""
        let allowed = try allowed.utf8()

        for codeUnit in self.utf8 {
            if allowed.contains(codeUnit) {
                string.append(UnicodeScalar(codeUnit))
            } else {
                string.append("%")
                string.append(codeUnit.hexadecimal())
            }
        }

        return string
    }
}

extension UInt8 {
    public func hexadecimal(uppercased: Bool = true) -> String {
        let hexadecimal =  String(self, radix: 16)
        return (self < 16 ? "0" : "") + (uppercased ? hexadecimal.uppercased() : hexadecimal)
    }
}
