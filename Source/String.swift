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

import System

extension String {
    public static func bufferWithSize(size: Int) -> [Int8] {
        return [Int8](count: size, repeatedValue: 0)
    }

    public init?(pointer: UnsafePointer<Int8>, length: Int) {
        var buffer = String.bufferWithSize(length + 1)
        strncpy(&buffer, pointer, length)

        guard let string = String.fromCString(buffer) else {
            return nil
        }

        self.init(string)
    }

	subscript (i: Int) -> Character? {
		guard i >= 0 && i < characters.count else { return nil }
		return self[startIndex.advancedBy(i)]
	}

	subscript (i: Range<Int>) -> String? {
		let start = i.startIndex, end = i.endIndex
		guard start >= 0 && start <= characters.count && end >= 0 && end <= characters.count && start < end else { return nil }
		return self[startIndex.advancedBy(start) ..< startIndex.advancedBy(end)]
	}

    public func split(separator: Character, maxSplit: Int = .max, allowEmptySlices: Bool = false) -> [String] {
		return characters.split(separator, maxSplit: maxSplit, allowEmptySlices: allowEmptySlices).map(String.init)
    }

    public func trim() -> String {
        return trim(CharacterSet.whitespaceAndNewline)
    }

    public func trim(characters: CharacterSet) -> String {
        let string = trimLeft(characters)
        return string.trimRight(characters)
    }

    public func trimLeft(characterSet: CharacterSet) -> String {
        var start = characters.count

        for (index, character) in characters.enumerate() {
            if !characterSet.contains(character) {
                start = index
                break
            }
        }

        return self[startIndex.advancedBy(start) ..< endIndex]
    }

    public func trimRight(characterSet: CharacterSet) -> String {
        var end = characters.count

        for (index, character) in characters.reverse().enumerate() {
            if !characterSet.contains(character) {
                end = index
                break
            }
        }

        return self[startIndex ..< startIndex.advancedBy(characters.count - end)]
    }

	public func indexOf(string: String) -> String.CharacterView.Index? {
		return characters.indexOf(string.characters)
	}
	
	public func contains(string: String) -> Bool {
		return indexOf(string) != nil
	}
	
	public func splitBy(separator: String) -> [String] {
		let separatorChars = separator.characters
		guard var index = characters.indexOf(separatorChars) else {
			return [self]
		}
		let separatorCount = separatorChars.count
		var start = characters.startIndex
		var array: [String] = []
		while true {
			let distance = characters.startIndex.distanceTo(index)
			let trange = start ..< characters.startIndex.advancedBy(distance + characters.startIndex.distanceTo(start))
			array.append(String(characters[trange]))
			start = start.advancedBy(distance + separatorCount)
			let substr = characters.suffixFrom(start)
			if let _index = substr.indexOf(separatorChars) {
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
			guard let index = characters.indexOf(strChars) else { break }
			replaceRange(index ..< index.advancedBy(strCount), with: with)
		}
	}
	
}

extension String.CharacterView {
	
	func indexOf(sequence: String.CharacterView) -> String.CharacterView.Index? {
		guard let firstChar = sequence.first else {
			return nil
		}
		let seqString = String(sequence)
		for (i, char) in enumerate() {
			guard char == firstChar else { continue }
			let start = startIndex.advancedBy(i)
			let end = startIndex.advancedBy(i+sequence.count)
			if String(self[start ..< end]) == seqString {
				return start
			}
		}
		return nil
	}
	
}

public struct CharacterSet: ArrayLiteralConvertible {
	public static var whitespaceAndNewline: CharacterSet {
		return [" ", "\t", "\r", "\n"]
	}

	public static var digits: CharacterSet {
		return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
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
}

extension String {
    public func startsWith(prefix: String) -> Bool {
        return prefix == String(self.characters.prefix(prefix.characters.count))
    }

    public func endsWith(suffix: String) -> Bool {
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
        case fixedSelf.startIndex.successor():
            return "/"

        // all common cases
        case let startOfLast:
            return String(fixedSelf.characters.prefixUpTo(startOfLast.predecessor()))
        }
    }

    var startOfLastPathComponent: String.CharacterView.Index {
        precondition(!endsWith("/") && characters.count > 1)

        let characterView = characters
        let startPos = characterView.startIndex
        let endPosition = characterView.endIndex
        var currentPosition = endPosition

        while currentPosition > startPos {
            let previousPosition = currentPosition.predecessor()
            if characterView[previousPosition] == "/" {
                break
            }
            currentPosition = previousPosition
        }

        return currentPosition
    }

    func fixSlashes(compress compress: Bool = true, stripTrailing: Bool = true) -> String {
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
                            afterLastSlashPosition = afterLastSlashPosition.successor()
                        }
                        if afterLastSlashPosition != currentPosition.successor() {
                            characterView.replaceRange(currentPosition ..< afterLastSlashPosition, with: ["/"])
                            endPosition = characterView.endIndex
                        }
                        currentPosition = afterLastSlashPosition
                    } else {
                        currentPosition = currentPosition.successor()
                    }
                }
            }
        }

        if stripTrailing && result.endsWith("/") {
            result.removeAtIndex(result.characters.endIndex.predecessor())
        }

        return result
    }
}

extension String {
    public init(percentEncoded: String) throws {
        struct Error: ErrorType, CustomStringConvertible {
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
        var generator = decodedBytes.generate()
        var finished = false

        while !finished {
            let decodingResult = decoder.decode(&generator)
            switch decodingResult {
            case .Result(let char): string.append(char)
            case .EmptyInput: finished = true
            case .Error:
                throw Error(description: "UTF-8 decoding failed")
            }
        }

        self.init(string)
    }
}